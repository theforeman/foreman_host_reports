N_('Host Reports summary')

notifications = [
  {
    :name               => 'ansible_host_report_summary',
    :description        => N_('A summary of eventful configuration management reports'),
    :mailer             => 'HostReportMailer',
    :method             => 'summary',
    :subscription_type  => 'report',
  },
  {
    :name               => 'puppet_host_report_summary',
    :description        => N_('A summary of eventful configuration management reports'),
    :mailer             => 'HostReportMailer',
    :method             => 'summary',
    :subscription_type  => 'report',
  },
  {
    :name               => 'ansible_failure_report',
    :description        => N_('A notification when a host report in ansible format had failed'),
    :mailer             => 'HostReportMailer',
    :method             => 'failure_state',
    :subscription_type  => 'alert',
  },
  {
    :name               => 'puppet_failure_report',
    :description        => N_('A notification when a host report in ansible format had failed'),
    :mailer             => 'HostReportMailer',
    :method             => 'failure_state',
    :subscription_type  => 'alert',
  }
]

notifications.each do |notification|
  format = notification[:name].include?('ansible') ? 'ansible' : 'puppet'
  if (mail = format == 'ansible' ? AnsibleFailureReport.find_by(name: notification[:name]) : PuppetFailureReport.find_by(name: notification[:name]))
    mail.attributes = notification
    mail.save! if mail.changed?
  else
    created_notification = format == 'ansible' ? AnsibleFailureReport.create(notification) : PuppetFailureReport.create(notification)
    if created_notification.nil? || created_notification.errors.any?
      raise ::Foreman::Exception.new(N_("Unable to create mail notification: %s"),
                                     format_errors(created_notification))
    end
  end
end
