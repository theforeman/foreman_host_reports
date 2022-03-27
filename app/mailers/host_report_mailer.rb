require 'uri'

class HostReportMailer < ApplicationMailer
  helper ApplicationHelper

  def initialize
    super
    @total_hosts_with_changes = 0
    @total_hosts_with_nochanges = 0
    @total_hosts_with_failure = 0
  end

  # sends out a summary email of hosts and their metrics (e.g. how many changes failures etc).
  def summary(options = {})
    @format = options[:format]
    @time = options[:time] || 1.day.ago

    user = User.find(options[:user])
    if user.nil?
      raise ::Foreman::Exception.new(N_("Must specify a valid user with email enabled"))
    end

    hosts = User.as user do
      Host::Managed.authorized_as(user, :view_hosts, Host).where('last_report > ?', @time).order(last_report: :desc).limit(100)
    end

    raise ::Foreman::Exception.new(N_("invalid host list")) unless hosts
    @hosts_status_data, @changed_hosts, @failed_hosts, @total_hosts = HostReport.summarise(hosts)
    @outofsync_hosts = Host.outofsync_hosts_list(@format)
    @disabled_hosts = Host.disabled_hosts_list(@format)

    total_host_status_data(@hosts_status_data)

    subject = format(
      _("Hosts latest Reports Summary - F:%<change>s R:%<nochange>s S:%<failure>s T:%<total>s"),
      :change => @total_hosts_with_changes,
      :nochange => @total_hosts_with_nochanges,
      :failure => @total_hosts_with_failure,
      :total => @total_hosts
    )

    set_locale_for(user) do
      mail(:to => user.mail, :subject => subject) do |format|
        format.html { render :layout => 'application_mailer' }
      end
    end
  end

  private

  def total_host_status_data(hosts_status_data)
    hosts_status_data.each_value do |host_status_data|
      @total_hosts_with_changes += host_status_data[:metrics][:change]
      @total_hosts_with_nochanges += host_status_data[:metrics][:nochange]
      @total_hosts_with_failure += host_status_data[:metrics][:failure]
    end
  end
end
