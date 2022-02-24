namespace :host_reports do
  desc "This task is only for development purposes, database tables must be clean before importing."
  task :import => :environment do
    Log.transaction do
      User.without_auditing do
        User.as_anonymous_admin do
          CSV.foreach("logs.csv", headers: true) do |l|
            log = Log.new
            log.id = l['id']
            log.source_id = l['source_id']
            log.message_id = l['message_id']
            log.report_id = l['report_id']
            log.level_id = l['level_id']
            log.save!
          end
        end
      end
    end
    ActiveRecord::Base.connection.exec_query("SELECT setval('logs_id_seq', (SELECT MAX(id) + 1 FROM logs), false)")

    Source.transaction do
      User.without_auditing do
        User.as_anonymous_admin do
          CSV.foreach("sources.csv", headers: true) do |s|
            source = Source.new
            source.id = s['id']
            source.value = s['value']
            source.save!
          end
        end
      end
    end
    ActiveRecord::Base.connection.exec_query("SELECT setval('sources_id_seq', (SELECT MAX(id) + 1 FROM sources), false)")

    Message.transaction do
      User.without_auditing do
        User.as_anonymous_admin do
          CSV.foreach("messages.csv", headers: true) do |m|
            message = Message.new
            message.id = m['id']
            message.value = m['value']
            message.save!
          end
        end
      end
    end
    ActiveRecord::Base.connection.exec_query("SELECT setval('messages_id_seq', (SELECT MAX(id) + 1 FROM messages), false)")

    Report.transaction do
      User.without_auditing do
        User.as_anonymous_admin do
          CSV.foreach("reports.csv", headers: true) do |r|
            report = ConfigReport.new
            report.id = r['id']
            report.host_id = r['host_id']
            report.reported_at = r['reported_at']
            report.created_at = r['created_at']
            report.updated_at = r['updated_at']
            report.status = JSON.parse(r['status'])
            report.metrics = JSON.parse(r['metrics'])
            report.type = r['type']
            report.origin = r['origin']
            report.save!
          end
        end
      end
    end
    ActiveRecord::Base.connection.exec_query("SELECT setval('reports_id_seq', (SELECT MAX(id) + 1 FROM reports), false)")
  end
end
