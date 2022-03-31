require 'uri'

class HostReportMailer < ApplicationMailer
  helper ApplicationHelper

  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).
  def summary(options = {})
    raise ::Foreman::Exception, N_("Must specify a valid user with email enabled") unless (user = User.find(options[:user]))
    hosts = User.as user do
      Host::Managed.authorized_as(user, :view_hosts, Host).order(:last_report).limit(100)
    end

    @format = options[:format]
    time = options[:time] || 1.day.ago
    host_data = HostReport.summarise(time, hosts, @format)
    total_metrics = load_metrics(host_data)
    total = 0
    total_metrics.each_value { |v| total += v }

    @hosts = host_data
    @timerange = time
    @out_of_sync = hosts.out_of_sync.sort
    @disabled = hosts.alerts_disabled.sort

    set_locale_for(user) do
      subject = format(
        _("Hosts latest Reports Summary - F:%<change>s R:%<nochange>s S:%<failure>s T:%<total>s"),
        :change => total_metrics["change"],
        :nochange => total_metrics["nochange"],
        :failure => total_metrics["failure"],
        :total => total
      )
      mail(:to => user.mail, :subject => subject) do |format|
        format.html { render :layout => 'application_mailer' }
      end
    end
  end

  def failure_state(report, options = {})
    @report = report
    @host = Host.find(@report.host_id)
    @format = options[:format]
    set_locale_for(options[:user]) do
      mail(:to => options[:user].mail, :subject => format(_("%<format>s Host Report has failed on %<host>s"), :format => @format, :host => @host)) do |format|
        format.html { render :layout => 'application_mailer' }
      end
    end
  end

  private

  def load_metrics(host_data)
    total_metrics = { "change" => 0, "nochange" => 0, "failure" => 0 }

    host_data.each_value do |data_hash|
      total_metrics["change"] += data_hash[:metrics][:change]
      total_metrics["nochange"] += data_hash[:metrics][:nochange]
      total_metrics["failure"] += data_hash[:metrics][:failure]
    end

    total_metrics
  end
end
