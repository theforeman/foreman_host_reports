class HostReport < ApplicationRecord
  include Authorizable

  delegate :logger, to: :Rails

  validates_lengths_from_database
  belongs_to_host
  belongs_to :proxy, class_name: 'SmartProxy'
  has_and_belongs_to_many :report_keywords

  has_one :organization, through: :host
  has_one :location, through: :host

  validates :host_id, :reported_at, :status, presence: true

  enum format: {
    # plain text report (no processing)
    plain: 0,
    # standard report (status + logs in plain text)
    puppet: 1,
    ansible: 2,
  }.freeze

  STATUS = {
    plain: %w[debug normal warning error],
  }.freeze

  scoped_search relation: :host, on: :name, complete_value: true, rename: :host, aliases: %i[host_name]
  scoped_search relation: :organization, on: :name, complete_value: true, rename: :organization
  scoped_search relation: :location, on: :name, complete_value: true, rename: :location
  scoped_search on: :reported_at, complete_value: true, default_order: :desc, rename: :reported, only_explicit: true, aliases: %i[last_report reported_at]
  scoped_search on: :host_id, complete_value: false, only_explicit: true
  scoped_search on: :proxy_id, complete_value: false, only_explicit: true
  scoped_search on: :format, complete_value: { plain: 0, puppet: 1, ansible: 2 }
  scoped_search relation: :report_keywords, on: :name, complete_value: true, rename: :keyword

  scope :recent, ->(*args) { where("reported_at > ?", (args.first || 1.day.ago)).order(:reported_at) }

  scope :my_reports, lambda {
    if !User.current.admin? || Organization.expand(Organization.current).present? || Location.expand(Location.current).present?
      joins_authorized(Host, :view_hosts)
    end
  }

  default_scope -> { order('reported_at DESC') }

  # TODO: temporary until we decide what will status bitfiled be exactly
  # rubocop:disable Style/RescueModifier
  def status
    @status ||= case format
                when 'puppet'
                  JSON.parse(body)['metrics']['resources']['values'] rescue []
                when 'ansible'
                  JSON.parse(body)['status'] rescue {}
                else
                  super
                end
  end
  # rubocop:enable Style/RescueModifier

  def self.authorized_smart_proxy_features
    @authorized_smart_proxy_features ||= %w[Puppet Ansible]
  end

  def self.register_smart_proxy_feature(feature)
    @authorized_smart_proxy_features = (authorized_smart_proxy_features + [feature]).uniq
  end

  def self.unregister_smart_proxy_feature(feature)
    @authorized_smart_proxy_features -= [feature]
  end
end
