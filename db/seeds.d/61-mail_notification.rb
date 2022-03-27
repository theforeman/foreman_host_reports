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
  }
]

notifications.each do |notification|
  if (mail = MailNotification.find_by(name: notification[:name]))
    mail.attributes = notification
    mail.save! if mail.changed?
  else
    created_notification = MailNotification.create(notification)
    if created_notification.nil? || created_notification.errors.any?
      raise ::Foreman::Exception.new(N_("Unable to create mail notification: %s"),
                                     format_errors(created_notification))
    end
  end
end
