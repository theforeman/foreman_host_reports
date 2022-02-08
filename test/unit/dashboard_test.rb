require 'test_plugin_helper'

class DashboardTest < ActiveSupport::TestCase
  include ForemanHostReports::ReportsDashboardHelper

  let(:ansible_report_with_change) { FactoryBot.create(:host_report, :ansible_format, :with_change) }
  let(:ansible_report_with_nochange) { FactoryBot.create(:host_report, :ansible_format, :with_nochange) }
  let(:ansible_report_with_failure) { FactoryBot.create(:host_report, :ansible_format, :with_failure) }

  let(:puppet_report_with_change) { FactoryBot.create(:host_report, :puppet_format, :with_change) }
  let(:puppet_report_with_nochange) { FactoryBot.create(:host_report, :puppet_format, :with_nochange) }
  let(:puppet_report_with_failure) { FactoryBot.create(:host_report, :puppet_format, :with_failure) }

  let(:puppet_format) { puppet_report_with_nochange.format }
  let(:ansible_format) { ansible_report_with_change.format }

  let(:host1) { ansible_report_with_change.host }
  let(:host2) { puppet_report_with_nochange.host }
  let(:host3) { puppet_report_with_failure.host }
  let(:hosts) { [host1, host2, host3] }

  test 'check number of host reports with changes and ansible format' do
    changed = ansible_report_with_change.change + ansible_report_with_nochange.change + ansible_report_with_failure.change
    assert_equal change_hosts(ansible_format), changed
  end

  test 'check number of host reports with changes and puppet format' do
    changed = puppet_report_with_change.change + puppet_report_with_nochange.change + puppet_report_with_failure.change
    assert_equal change_hosts(puppet_format), changed
  end

  test 'check number of host reports with no changes and ansible format' do
    nochange = ansible_report_with_change.nochange + ansible_report_with_nochange.nochange + ansible_report_with_failure.nochange
    assert_equal nochange_hosts(ansible_format), nochange
  end

  test 'check number of host reports with no changes and puppet format' do
    nochange = puppet_report_with_change.nochange + puppet_report_with_nochange.nochange + puppet_report_with_failure.nochange
    assert_equal nochange_hosts(puppet_format), nochange
  end

  test 'check number of host reports with failures and ansible format' do
    failure = ansible_report_with_change.failure + ansible_report_with_nochange.failure + ansible_report_with_failure.failure
    assert_equal failure_hosts(ansible_format), failure
  end

  test 'check number of host reports with failures and puppet format' do
    failure = puppet_report_with_change.failure + puppet_report_with_nochange.failure + puppet_report_with_failure.failure
    assert_equal failure_hosts(puppet_format), failure
  end

  test 'check Hosts with disabled alerts ' do
    host1.update(:enabled => false)
    disabled = hosts.reject(&:enabled?)
    assert_equal disabled_hosts, disabled.count
  end

  test 'latest_reports' do
    FactoryBot.create(:host_report, :ansible_format, :with_change)
    FactoryBot.create(:host_report, :ansible_format, :with_nochange)
    as_admin do
      assert_equal latest_reports.count, 2
    end
  end
end
