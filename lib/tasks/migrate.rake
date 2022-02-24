namespace :reports do
  def keywords(status)
    keywords_set = {}
    keywords_set["PuppetFailed"] = true if status["failed"] == 1
    keywords_set["PuppetFailedToRestart"] = true if status["failed_restarts"] == 1
    keywords_set["PuppetCorrectiveChange"] = true if status["corrective_change"] == 1
    keywords_set["PuppetSkipped"] = true if status["skipped"] == 1
    keywords_set["PuppetRestarted"] = true if status["restarted"] == 1
    keywords_set["PuppetScheduled"] = true if status["scheduled"] == 1
    keywords_set["PuppetOutOfSync"] = true if status["out_of_sync"] == 1
  end

  def summary(metrics)
    change, failure, nochange = metrics_values(metrics)
    {
      :foreman => {
        :change => change,
        :nochange => nochange,
        :failure => failure,
      },
      :native => metrics[:resources],
    }
  end

  def metrics_values(metrics)
    change = metrics.dig("events", "success")
    failure = metrics.dig("events", "failure")
    total = metrics.dig("events", "total")
    nochange = total - change - failure
    [change, failure, nochange]
  end

  def create_body(metrics, reported_at, status, logs, host)
    {
      :migrated => "true",
      :host => host,
      :reported_at => reported_at,
      :logs => logs,
      :keywords => keywords(status),
      :summary => summary(metrics),
    }
  end

  def host_report_create(host_id, origin, body)
    {
      :host_id => host_id,
      :proxy_id => nil,
      :format => origin,
      :reported_at => body[:reported_at],
      :body => body.to_json,
      :change => body[:summary][:foreman][:change],
      :nochange => body[:summary][:foreman][:nochange],
      :failure => body[:summary][:foreman][:failure],
    }
  end

  task :migrate => :environment do
    ConfigReport.all.order(id: :asc).where("id >= ?", (ENV['start'] || '0').to_i).each do |r|
      if r.origin != "Puppet"
        next
      end
      body = create_body(r.metrics, r.reported_at, r.status, r.logs, r.host)
      origin = r.origin.downcase
      host_report = host_report_create(r.host_id, origin, body)
      User.without_auditing do
        User.as_anonymous_admin do
          HostReport.create(host_report)
        end
      end
    rescue StandardError => e
      puts "An error occurred, to resume the process: foreman-rake host_reports:migrate from=#{r.reported_at} start=#{r.id}"
      throw e
    end
    puts "Successfully migrated from ID #{ENV['start'] || 0} to #{ConfigReport.last.id}."
  end
end
