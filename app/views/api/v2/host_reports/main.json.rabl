# frozen_string_literal: true

object @host_report

extends 'api/v2/host_reports/base'
extends 'api/v2/layouts/permissions'

attributes :format, :host_id, :proxy_id, :reported_at

node(:host_name) do |report|
  report.host.name
end
node(:proxy_name) do |report|
  report.proxy&.name
end
