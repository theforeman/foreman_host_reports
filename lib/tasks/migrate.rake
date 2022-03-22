PUPPET_LOG_LEVELS = %w[debug info notice warning err alert emerg crit].freeze
reports_migrate_running = true

namespace :host_reports do
  def detect_puppet_keywords(status, logs)
    result = ["Migrated"]
    # from statuses
    result << "PuppetFailed" if status["failed"]&.positive?
    result << "PuppetFailedToRestart" if status["failed_restarts"]&.positive?
    result << "PuppetCorrectiveChange" if status["corrective_change"]&.positive?
    result << "PuppetSkipped" if status["skipped"]&.positive?
    result << "PuppetRestarted" if status["restarted"]&.positive?
    result << "PuppetScheduled" if status["scheduled"]&.positive?
    result << "PuppetOutOfSync" if status["out_of_sync"]&.positive?
    # from logs
    logs.each do |level, resource, _message|
      result << "PuppetFailed:#{resource}" if level == "err" && resource != "Puppet"
    end
    result.uniq
  end

  # Puppet status cannot be directly mapped, let's create unique migration-only keywords.
  # See: https://community.theforeman.org/t/new-config-report-summary-columns/26531
  def detect_ansible_keywords(status)
    result = ["Migrated"]
    # from statuses
    result << "AnsibleMigrate:Applied" if status["applied"]&.positive?
    result << "AnsibleMigrate:Restarted" if status["restarted"]&.positive?
    result << "AnsibleMigrate:Failed" if status["failed"]&.positive?
    result << "AnsibleMigrate:FailedRestarts" if status["failed_restarts"]&.positive?
    result << "AnsibleMigrate:Skipped" if status["skipped"]&.positive?
    result << "AnsibleMigrate:Pending" if status["pending"]&.positive?
    result.uniq
  end

  def puppet_metrics(metrics)
    return [0, 0, 0] if metrics.empty?
    change = metrics.dig("events", "success") || 0
    failure = metrics.dig("events", "failure") || 0
    total = metrics.dig("events", "total") || 0
    nochange = total - change - failure
    [change, failure, nochange]
  end

  def create_summary(origin, metrics, status)
    change, failure, nochange = 0
    case origin
    when "Puppet"
      change, failure, nochange = puppet_metrics(metrics)
    when "Ansible"
      # There is not enough data to construct the summary, it is not possible to
      # efficiently map ansible status values to the new format. See the discussion
      # at: https://community.theforeman.org/t/new-config-report-summary-columns/26531
      failure = status["failed"]
      change = status["applied"]
      nochange = status["skipped"]
    end

    {
      foreman: {
        change: change,
        nochange: nochange,
        failure: failure,
      },
      native: metrics[:resources] || {},
      legacy_status: status || {},
    }
  end

  def create_body(format, metrics, reported_at, _status, host, keywords, summary)
    {
      version: 1,
      format: format,
      migrated: true,
      host: host.name,
      reported_at: reported_at,
      keywords: keywords,
      summary: summary,
      # metrics cannot be migrated because Foreman stores them in its own way and
      # the new host format uses puppet native version
      metrics: {
        resources: { values: [] },
        time: { values: [] },
        changes: { values: [] },
        events: { values: [] },
      },
      # keep the legacy metrics in the body in case we reconsider and transform it later
      legacy_metrics: metrics,
    }
  end

  def build_report(host_id, origin, body, report_keyword_ids)
    {
      host_id: host_id,
      proxy_id: nil,
      format: origin,
      reported_at: body[:reported_at],
      body: body.to_json,
      change: body.dig(:summary, :foreman, :change),
      nochange: body.dig(:summary, :foreman, :nochange),
      failure: body.dig(:summary, :foreman, :failure),
      report_keyword_ids: report_keyword_ids,
    }
  end

  def create_puppet_logs(id, log_object)
    logs = [["debug", "migration", "Report migrated from legacy report ID=#{id} at #{Time.now.utc}"]]
    log_object.includes(:message, :source).find_each do |log|
      logs << [PUPPET_LOG_LEVELS[log.level_id] || 'unknown', log.source.value, log.message.value]
    end
    logs
  end

  def create_ansible_result(msg, level, result = {}, task = {})
    {
      failed: false,
      level: level,
      friendly_message: msg,
      result: result,
      task: task,
    }
  end

  def create_ansible_results(id, log_object)
    results = []
    results << create_ansible_result("Report migrated from legacy report ID=#{id} at #{Time.now.utc}", "info")
    log_object.includes(:message, :source).find_each do |log|
      lvl = PUPPET_LOG_LEVELS[log.level_id] || 'unknown'
      msg = begin
        JSON.parse(log.message.value)
      rescue StandardError
        log.message.value
      end
      results << create_ansible_result(log.source.value, lvl, msg)
    end
    results
  end

  desc <<-END_DESC
  Migrates Foreman Configuration Reports to the new Host Reports format.
  Does not delete legacy reports, can be iterrupted at any time.
  Accepts from_date option (older reports will be ignored) and from_id,
  primary key (ID) to start migration from which can be used to resume
  previously stopped migration. Example:

  foreman-rake host_reports:migrate from_date=2021-01-01 from_id=1234567
  END_DESC
  task :migrate => :environment do
    Rails.logger.level = Logger::ERROR
    Foreman::Logging.logger('permissions').level = Logger::ERROR
    Foreman::Logging.logger('audit').level = Logger::ERROR
    Signal.trap("INT") do
      reports_migrate_running = false
    end
    Signal.trap("TERM") do
      reports_migrate_running = false
    end

    from_id = (ENV['from_id'] || '0').to_i
    from_date = ENV['from_date'] || '1980-01-15'
    report_count = ConfigReport.unscoped.where("id >= ? and reported_at >= ?", from_id, from_date).count
    print_each = 1 + (report_count / 100).to_i
    puts "Starting, #{report_count} report(s) left"
    counter = 0
    ConfigReport.unscoped.all.where("id >= ? and reported_at >= ?", from_id, from_date).find_each do |r|
      raise("Interrupted") unless reports_migrate_running
      counter += 1
      puts("Processing report #{counter} out of #{report_count} reports") if (counter % print_each).zero?
      case r.origin
      when "Puppet"
        logs = create_puppet_logs(r.id, r.logs)
        keywords = detect_puppet_keywords(r.status, logs)
      when "Ansible"
        results = create_ansible_results(r.id, r.logs)
        keywords = detect_ansible_keywords(r.status)
      end
      if keywords.present?
        keywords_to_insert = keywords.each_with_object([]) do |n, ks|
          ks << { name: n }
        end
        ReportKeyword.upsert_all(keywords_to_insert, unique_by: :name)
        report_keyword_ids = ReportKeyword.where(name: keywords).distinct.pluck(:id)
      end
      summary = create_summary(r.origin, r.metrics, r.status)
      body = create_body(r.origin&.downcase, r.metrics, r.reported_at, r.status, r.host, report_keyword_ids, summary)
      case r.origin
      when "Puppet"
        body[:logs] = logs
      when "Ansible"
        body[:results] = results
      end
      origin = r.origin.downcase
      User.without_auditing do
        User.as_anonymous_admin do
          HostReport.create!(build_report(r.host_id, origin, body, report_keyword_ids))
        end
      end
    rescue StandardError => e
      puts "Error when processing report ID=#{r.id}"
      puts r.inspect
      puts "To resume the process:\n\n***\n\nforeman-rake host_reports:migrate from_id=#{r.id} from_date=#{from_date}\n\n***\n\n"
      raise e
    end
    puts "\n\nALL DONE!\n\nCheck the migrated reports in Monitor - Host Reports first"
    puts "and when ready, expire old configuration reports with:\n\n"
    puts "  rake reports:expire report_type=config_report days=0\n\n"
    puts "Report expiration is slow, if you don't use OpenSCAP plugin, then"
    puts "truncate the following tables in the foreman database"
    puts "for a quick delete (this will remove also OpenSCAP reports):\n\n"
    puts "  truncate logs, messages, resources, reports;\n\n"
    puts "Reclaim postgres database space via VACUUM function in any case."
    puts "If migration was not successful, truncate tables host_reports and"
    puts "report_keywords and start over.\n"
    puts "Optionally, refresh host statuses with:\n\n"
    puts "  foreman-rake host_reports:refresh\n\n"
  end

  desc <<-END_DESC
  Host status information can be incorrect until new report is received.
  This task refreshes all host statuses and global statuses.
  END_DESC
  task :refresh => :environment do
    # ensure the class is loaded before refresh starts to avoid hash modifycation during loop
    _ = HostStatus::HostReportStatus

    Rails.logger.level = Logger::ERROR
    Foreman::Logging.logger('permissions').level = Logger::ERROR
    Foreman::Logging.logger('audit').level = Logger::ERROR
    User.without_auditing do
      User.as_anonymous_admin do
        # delete old and new statuses
        HostStatus::Status.where(type: "HostStatus::ConfigurationStatus").delete_all
        HostStatus::Status.where(type: "HostStatus::HostReportStatus").delete_all

        # refresh all statuses from scratch
        Host.unscoped.all.find_each do |h|
          h.refresh_statuses
          h.refresh_global_status
        end
      end
    end
  end
end
