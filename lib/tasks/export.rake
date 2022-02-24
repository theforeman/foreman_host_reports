require 'csv'

namespace :host_reports do
  desc "Export all reports as CSV files. This task is only for development purposes."
  task :export => :environment do
    CSV.open("logs.csv", "w") do |lcsv|
      lcsv << %w[id source_id message_id report_id level_id]
      Log.find_each do |l|
        lcsv << [l.id, l.source_id, l.message_id, l.report_id, l.level_id]
      end
    end

    CSV.open("sources.csv", "w") do |scsv|
      scsv << %w[id value]
      Source.find_each do |s|
        scsv << [s.id, s.value]
      end
    end

    CSV.open("messages.csv", "w") do |mcsv|
      mcsv << %w[id value]
      Message.find_each do |m|
        mcsv << [m.id, m.value]
      end
    end

    CSV.open("reports.csv", "w") do |rcsv|
      rcsv << %w[id host_id reported_at created_at updated_at status metrics type origin]
      ConfigReport.find_each do |r|
        next if r.type != "ConfigReport"
        rcsv << [r.id, r.host_id, r.reported_at, r.created_at, r.updated_at, r.status.to_json, r.metrics.to_json, r.type, r.origin]
      end
    end
  end
end
