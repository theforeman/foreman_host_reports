module ForemanHostReports
  module Controller
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def preload_reports
          @last_report_ids = HostReport.where(:host_id => @hosts.map(&:id)).reorder('').group(:host_id).maximum(:id)
          @last_reports = HostReport.where(:id => @last_report_ids.values)
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
