module Fhr
  class StandardReportImporter
    attr_accessor :body, :format

    def initialize(body, format)
      @body = body
      @format = format.to_s
    end

    def build_host_report
      host = Host.find_by_name(body["host"])
      return nil unless host
      HostReport.build(
        host_id: host.id,
        reported_at: body["reported_at"] || Time.now.utc,
        status: 0, # StatusCalculator TODO
        body: body,
        format: HostReport.formats[format]
      )
    end
  end
end
