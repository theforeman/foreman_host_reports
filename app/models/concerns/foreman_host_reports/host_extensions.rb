module ForemanHostReports
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_many :host_reports, foreign_key: :host_id, class_name: 'HostReport', inverse_of: :host, dependent: :destroy
      has_one :last_host_report_object_any_format, -> { order("#{HostReport.table_name}.reported_at DESC, #{HostReport.table_name}.id").limit(1) }, foreign_key: :host_id, class_name: 'HostReport', inverse_of: :host, dependent: :delete
      has_one :host_report_status_object, class_name: 'HostStatus::HostReportStatus', foreign_key: :host_id, inverse_of: :host, dependent: :delete

      scoped_search relation: :host_reports, on: :change, rename: :report_changes, only_explicit: true
      scoped_search relation: :host_reports, on: :nochange, rename: :report_nochanges, only_explicit: true
      scoped_search relation: :host_reports, on: :failure, rename: :report_failures, only_explicit: true
      scoped_search relation: :host_reports, on: :format, rename: :report_format, only_explicit: true, complete_value: { plain: 0, puppet: 1, ansible: 2 }
    end
  end
end
