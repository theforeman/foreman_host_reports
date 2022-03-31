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

  after_commit :send_failure_mail

  scoped_search relation: :host, on: :name, complete_value: true, rename: :host, aliases: %i[host_name]
  scoped_search relation: :proxy, on: :name, complete_value: true, rename: :proxy
  scoped_search relation: :organization, on: :name, complete_value: true, rename: :organization
  scoped_search relation: :location, on: :name, complete_value: true, rename: :location
  scoped_search on: :change, aliases: %i[changed changes]
  scoped_search on: :nochange, aliases: %i[unchanged nochanges]
  scoped_search on: :failure, aliases: %i[failed failures]
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

  def self.search_by_keyword(_key, operator, value)
    conditions = sanitize_sql_for_conditions(["report_keywords.name #{operator} ?", value_to_sql(operator, value)])
    keyword_ids = ReportKeyword.where(conditions).distinct.pluck(:id)
    {
      conditions: sanitize_sql_for_conditions(["host_reports.report_keyword_ids @> ?", "{#{keyword_ids.join(',')}}"]),
    }
  end

  def status
    if failure&.positive?
      :failure
    elsif change&.positive?
      :change
    elsif nochange&.positive?
      :nochange
    else
      :empty
    end
  end

  def self.report_tag(level)
    tag = case level
          when :notice
            "info"
          when :warning
            "warning"
          when :err
            "danger"
          else
            "default"
          end
    "class='label label-#{tag} result-filter-tag'".html_safe
  end

  private

  def send_failure_mail
    return unless status == :failure
    host = Host.find(host_id)
    if host.disabled?
      logger.warn "#{host.name} is disabled - skipping alert"
      return
    end
    report_format = format == "ansible" ? "ansible" : "puppet"
    notification = report_format << "_failure_report"
    owners = host.owner.present? ? host.owner.recipients_for(notification.to_sym) : []
    users = report_format == :ansible_failure_report ? AnsibleFailureReport.all_hosts.flat_map(&:users) : PuppetFailureReport.all_hosts.flat_map(&:users)
    users = users.select do |user|
      User.as user do
        Host.authorized_as(user, :view_hosts).find(host.id).present?
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
    owners.concat users
    if owners.present?
      logger.debug { "sending alert to #{owners.map(&:login).join(',')}" }
      MailNotification[notification].deliver(self, :users => owners.uniq)
    else
      logger.debug { "no owner or recipients for alert on #{host.name}" }
    end
  end
end
