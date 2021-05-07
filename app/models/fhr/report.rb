module Fhr
  class Report < ApplicationRecord
    belongs_to :hosts

    enum format: {
      # plain text report (no processing)
      plain_full: 0,
      plain_archived: 10,
      # standard report (status + logs in plain text)
      standard_full: 1000,
      standard_archived: 1010,
    }.freeze

    IMPORTER = {
      standard_full: Fhr::StandardReportImporter,
    }.freeze

    STATUS = {
      standard_full: %w[debug normal warning error],
    }.freeze

    def self.import(body, format_from_url = nil)
      format = format_from_url || body["format"]&.to_s
      raise("No host report format provided") unless format
      importer = IMPORTER[format.to_sym]
      raise("Unknown importer for format: #{format}") unless importer
      report = importer.new(body, format).build_host_report
      report.save!
    end
  end
end