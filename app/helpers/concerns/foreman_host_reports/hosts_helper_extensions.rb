module ForemanHostReports
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    module Overrides
      def last_report_column(record)
        opts = { :rel => "twipsy" }
        date = record.last_report.nil? ? '' : "#{date_time_absolute_value(record.last_report)}, "
        time = record.last_report? ? date_time_relative_value(record.last_report) : ""
        if @last_report_ids[record.id]
          opts["data-original-title"] = date + _("view last report details")
          link_to_if_authorized(time, hash_for_host_report_path(:id => record.last_host_report_object_any_format&.id), opts)
        else
          opts.merge!(:disabled => true, :class => "disabled", :onclick => 'return false')
          opts["data-original-title"] = date + _("report already deleted") unless record.last_report.nil?
          link_to_if_authorized(time, hash_for_host_reports_path, opts)
        end
      end
    end

    included do
      prepend Overrides
    end
  end
end
