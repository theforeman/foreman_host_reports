module HostStatus
  # rubocop:disable Style/GuardClause
  class HostReportStatus < Status
    def last_report
      self.last_report = host.last_host_report_object unless @last_report_set
      @last_report
    end

    def last_report=(report)
      @last_report_set = true
      @last_report = report
    end

    # <host report fields>
    def change
      last_report&.change || 0
    end

    def nochange
      last_report&.nochange || 0
    end

    def failure
      last_report&.failure || 0
    end

    def change?
      change.positive?
    end

    def nochange?
      nochange.positive?
    end

    def failure?
      failure.positive?
    end
    # </host report fields>

    # <legacy report compatibility fields>
    def restarted
      0
    end

    def failed_restarts
      0
    end

    def skipped
      0
    end
    # </legacy report compatibility fields>

    def expected_report_interval
      (reported_format_interval.presence || default_report_interval).to_i.minutes
    end

    def reported_format_interval
      if host.params.key? "#{last_report.format.downcase}_interval"
        host.params["#{last_report.format.downcase}_interval"]
      else
        Setting[:"#{last_report.format.downcase}_interval"]
      end
    end

    def out_of_sync?
      if (host && !host.enabled?) || no_reports? || out_of_sync_disabled?
        false
      else
        !reported_at.nil? && reported_at < (Time.now.utc - expected_report_interval)
      end
    end

    def no_reports?
      host && last_report.nil?
    end

    def self.status_name
      N_("Configuration")
    end

    # Constants are bit-mask friendly in case we want to query them in the DB
    UNKNOWN     = -0b000000000000010000000000000000 # -65536
    FAILURES    = -0b000000000000000000000000000001 # -1
    EMPTY       =  0b000000000000000000000000000000 # 0
    NO_CHANGES  =  0b000000000000000000000100000000 # 256
    CHANGES     =  0b000000000000010000000000000000 # 65536

    LABELS = {
      FAILURES => N_("Failure(s)"),
      EMPTY => N_("Empty"),
      NO_CHANGES => N_("No changes"),
      CHANGES => N_("Changes applied"),
    }.freeze

    def to_label(_options = {})
      if host && !host.enabled
        return N_("Alerts disabled")
      elsif out_of_sync?
        return N_("Out of sync")
      end

      LABELS.fetch(to_status, N_("Unknown config status"))
    end

    def to_global(options = {})
      handle_options(options)

      if failure?
        HostStatus::Global::ERROR
      elsif out_of_sync?
        HostStatus::Global::WARN
      elsif no_reports? && (host.configuration? || Setting[:always_show_configuration_status])
        HostStatus::Global::WARN
      else
        HostStatus::Global::OK
      end
    end

    def to_status(options = {})
      handle_options(options)

      if host&.enabled && last_report.present?
        if last_report.failure.positive?
          FAILURES
        elsif last_report.change.positive?
          CHANGES
        elsif last_report.nochange.positive?
          NO_CHANGES
        else
          EMPTY
        end
      else
        UNKNOWN
      end
    end

    def relevant?(options = {})
      handle_options(options)

      host.configuration? || last_report.present? || Setting[:always_show_configuration_status]
    end

    def status_link
      return @status_link if defined?(@status_link)
      return @status_link = nil if last_report.nil?
      return @status_link = nil unless User.current.can?(:view_host_reports, last_report, false)

      @status_link = last_report && Rails.application.routes.url_helpers.host_report_path(last_report)
    end

    private

    # Configuration status can be calculated from database state, but also reports can be
    # passed in via options. In that case, report is matched with the host and set.
    # Don't ask me why this is implemented this way, this is copy-paste from the original
    # ConfigurationStatus in Foreman core.
    def handle_options(options)
      if options.key?(:last_reports) && !options[:last_reports].nil?
        cached_report = options[:last_reports].find { |r| r.host_id == host_id }
        self.last_report = cached_report
      end
    end

    def update_timestamp
      self.reported_at = last_report.try(:reported_at) || Time.now.utc
    end

    def default_report_interval
      if host.params.key? 'outofsync_interval'
        host.params['outofsync_interval']
      else
        Setting[:outofsync_interval]
      end
    end

    def out_of_sync_disabled?
      Setting[:"#{last_report.format.downcase}_out_of_sync_disabled"]
    end
  end
  # rubocop:enable Style/GuardClause
end

HostStatus.status_registry.delete(HostStatus::ConfigurationStatus)
HostStatus.status_registry.add(HostStatus::HostReportStatus)
