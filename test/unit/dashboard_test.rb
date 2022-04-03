require 'test_plugin_helper'

class DashboardTest < ActiveSupport::TestCase
  include ForemanHostReports::ReportsDashboardHelper

  test 'latest_reports' do
    FactoryBot.create(:host_report, :ansible_format, :with_change)
    FactoryBot.create(:host_report, :ansible_format, :with_nochange)
    as_admin do
      assert_equal latest_reports.count, 2
    end
  end

  %w[puppet ansible].each do |format|
    test "no events #{format} host" do
      FactoryBot.create(:host_report, :recent, format: format)
      assert_equal 1, Host.noevents_hosts(format)
    end

    test "empty #{format} host" do
      FactoryBot.create(:host_report, :recent, :empty, format: format)
      assert_equal 1, Host.noreports_hosts(format)
    end

    test "out of sync #{format} host" do
      FactoryBot.create(:host_report, :outofsync, format: format)
      assert_equal 1, Host.outofsync_hosts(format)
    end

    test "failed #{format} host" do
      FactoryBot.create(:host_report, :recent, :with_failure, format: format)
      assert_equal 1, Host.failure_hosts(format)
    end

    test "change #{format} host" do
      FactoryBot.create(:host_report, :recent, :with_change, format: format)
      assert_equal 1, Host.change_hosts(format)
    end

    test "nochange #{format} host" do
      FactoryBot.create(:host_report, :recent, :with_nochange, format: format)
      assert_equal 1, Host.nochange_hosts(format)
    end
  end
end
