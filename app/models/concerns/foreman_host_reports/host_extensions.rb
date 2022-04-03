module ForemanHostReports
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_many :host_reports, foreign_key: :host_id, class_name: 'HostReport', inverse_of: :host, dependent: :destroy
      has_one :host_report_status_object, class_name: 'HostStatus::HostReportStatus', foreign_key: :host_id, inverse_of: :host, dependent: :delete

      scoped_search relation: :host_reports, on: :change, rename: :report_changes, only_explicit: true
      scoped_search relation: :host_reports, on: :nochange, rename: :report_nochanges, only_explicit: true
      scoped_search relation: :host_reports, on: :failure, rename: :report_failures, only_explicit: true
      scoped_search relation: :host_reports, on: :format, rename: :report_format, only_explicit: true, complete_value: { plain: 0, puppet: 1, ansible: 2 }

      def last_host_report_object
        host_reports.reorder("#{HostReport.table_name}.id DESC").limit(1)&.first
      end

      def configuration_status(options = {})
        @configuration_status ||= get_status(HostStatus::HostReportStatus).to_status(options)
      end

      def configuration_status_label(options = {})
        @configuration_status_label ||= get_status(HostStatus::HostReportStatus).to_label(options)
      end
    end

    class_methods do
      def interval_query(format)
        interval_setting = (Setting[:"#{format}_interval"] || Setting[:outofsync_interval]).to_i
        "\"#{interval_setting} minutes ago\""
      end

      def failure_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and " \
          "report_failures > 0 and last_report > #{interval_query(format)} and status.enabled = true"
      end

      def failure_hosts(format, prefix = '')
        Host.search_for(failure_hosts_query(format, prefix)).reorder("").count
      end

      def change_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and " \
          "report_failures = 0 and report_changes > 0 and last_report > #{interval_query(format)} and status.enabled = true"
      end

      def change_hosts(format, prefix = '')
        Host.search_for(change_hosts_query(format, prefix)).reorder("").count
      end

      def nochange_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and " \
          "report_failures = 0 and report_changes = 0 and report_nochanges > 0 and last_report > #{interval_query(format)} and status.enabled = true"
      end

      def nochange_hosts(format, prefix = '')
        Host.search_for(nochange_hosts_query(format, prefix)).reorder("").count
      end

      def noevents_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and " \
          "report_failures = 0 and report_changes = 0 and report_nochanges = 0 and last_report > #{interval_query(format)} and status.enabled = true"
      end

      def noevents_hosts(format, prefix = '')
        Host.search_for(noevents_hosts_query(format, prefix)).reorder("").count
      end

      def noreports_hosts_query(_format, prefix = '')
        # always across all formats because there are no reports (thus format is unknown)
        "#{prefix}null? last_report"
      end

      def noreports_hosts(format, prefix = '')
        Host.search_for(noreports_hosts_query(format, prefix)).reorder("").count
      end

      def outofsync_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and last_report <= #{interval_query(format)} and status.enabled = true"
      end

      def outofsync_hosts(format, prefix = '')
        Host.search_for(outofsync_hosts_query(format, prefix)).reorder("").count
      end

      def disabled_hosts_query(format, prefix = '')
        prefix + "report_format = #{format} and status.enabled = false"
      end

      def disabled_hosts(format, prefix = '')
        Host.search_for(disabled_hosts_query(format, prefix)).reorder("").count
      end
    end
  end
end
