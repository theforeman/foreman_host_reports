# frozen_string_literal: true

object @host_report

extends 'api/v2/host_reports/main'

attributes :status, :body

node :keywords do |report|
  report.report_keywords.map(&:name)
end
