class HostReport < ApplicationRecord
  include Authorizable
  include ScopedSearchExtensions

  delegate :logger, to: :Rails

  validates_lengths_from_database
  belongs_to_host
  belongs_to :proxy, class_name: 'SmartProxy'
  has_one :organization, through: :host
  has_one :location, through: :host

  validates :host_id, :reported_at, presence: true

  enum format: {
    # plain text report (no processing)
    plain: 0,
    # standard report (status + logs in plain text)
    puppet: 1,
    ansible: 2,
  }.freeze

  scoped_search relation: :host, on: :name, complete_value: true, rename: :host, aliases: %i[host_name]
  scoped_search relation: :proxy, on: :name, complete_value: true, rename: :proxy
  scoped_search relation: :organization, on: :name, complete_value: true, rename: :organization
  scoped_search relation: :location, on: :name, complete_value: true, rename: :location
  scoped_search on: :reported_at, complete_value: true, default_order: :desc, rename: :reported, only_explicit: true, aliases: %i[last_report reported_at]
  scoped_search on: :format, complete_value: { plain: 0, puppet: 1, ansible: 2 }
  # This is to simulate has_many :report_keywords relation for scoped_search library to work
  # NOTE: This won't work for any other purpose
  reflections['report_keywords'] = ReportKeyword
  scoped_search relation: :report_keywords, on: :name, complete_value: true, rename: :keyword, ext_method: :search_by_keyword, operators: ['=']

  scope :recent, ->(*args) { where("reported_at > ?", (args.first || 1.day.ago)).order(:reported_at) }

  scope :my_reports, lambda {
    if !User.current.admin? || Organization.expand(Organization.current).present? || Location.expand(Location.current).present?
      joins_authorized(Host, :view_hosts)
    end
  }

  default_scope -> { order('reported_at DESC') }

  def report_keywords
    ReportKeyword.where(id: report_keyword_ids)
  end

  def self.authorized_smart_proxy_features
    @authorized_smart_proxy_features ||= %w[Puppet Ansible]
  end

  def self.register_smart_proxy_feature(feature)
    @authorized_smart_proxy_features = (authorized_smart_proxy_features + [feature]).uniq
  end

  def self.unregister_smart_proxy_feature(feature)
    @authorized_smart_proxy_features -= [feature]
  end

  def self.search_by_keyword(_key, operator, value)
    conditions = sanitize_sql_for_conditions(["report_keywords.name #{operator} ?", value_to_sql(operator, value)])
    keyword_ids = ReportKeyword.where(conditions).distinct.pluck(:id)
    {
      conditions: sanitize_sql_for_conditions(["host_reports.report_keyword_ids @> ?", "{#{keyword_ids.join(',')}}"]),
    }
  end
end
