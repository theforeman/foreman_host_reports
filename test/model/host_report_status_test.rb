require 'test_helper'

class HostReportStatusTest < ActiveSupport::TestCase
  let(:report) { FactoryBot.create(:host_report) }
  let(:host) { report.host }
  let(:status) { HostStatus::HostReportStatus.new(host: host).tap(&:refresh) }

  test 'is valid' do
    assert_valid status
  end

  test 'last_report defaults to hosts last if nothing was set yet' do
    assert_equal report, status.last_report
  end

  test '#last_report returns custom value that was set using writer method' do
    status.last_report = :something
    assert_equal :something, status.last_report
  end

  test '#last_report returns custom value that was set using writer method even for nil' do
    status.last_report = nil
    assert_nil status.last_report
  end

  test "last_host_report_object returns latest report" do
    assert_equal report, host.last_host_report_object
  end

  test "empty configuration status host attribute" do
    assert_equal 0, host.configuration_status
  end

  test "empty configuration status host attribute label" do
    assert_equal "Empty", host.configuration_status_label
  end

  test "empty configuration status host attribute" do
    report.failure = 5
    report.save!
    assert_equal(-1, host.configuration_status)
  end

  test "empty configuration status host attribute label" do
    report.failure = 5
    report.save!
    assert_equal "Failure(s)", host.configuration_status_label
  end

  describe "host with no reports" do
    let(:host) { FactoryBot.create(:host) }

    test '#no_reports? results in warning only if puppet reports are expected' do
      refute host.last_report

      status.stubs(:error? => false)
      status.stubs(:out_of_sync? => false)
      status.stubs(:no_reports? => true)
      assert_equal HostStatus::Global::OK, status.to_global

      host.expects(:configuration? => true)
      assert_equal HostStatus::Global::WARN, status.to_global

      host.expects(:configuration? => false)
      Setting[:always_show_configuration_status] = true
      assert_equal HostStatus::Global::WARN, status.to_global
    end
  end

  test 'status is disabled when reporting is disabled' do
    host.enabled = false
    assert_equal HostStatus::HostReportStatus::UNKNOWN, status.refresh
  end

  test '#out_of_sync? is false when reported_at is unknown' do
    status.reported_at = nil
    refute status.out_of_sync?
  end

  test '#out_of_sync? is false when window is big enough' do
    original = Setting[:outofsync_interval]
    Setting[:outofsync_interval] = (Time.now.utc - report.reported_at).to_i / 60 + 1
    refute status.out_of_sync?
    Setting[:outofsync_interval] = original
  end

  describe '#out_of_sync?' do
    let(:report) { FactoryBot.create(:host_report, reported_at: Time.now.utc - 1.year) }

    test '#out_of_sync? is false when out of sync is disabled' do
      status.stubs(:out_of_sync_disabled?).returns(true)
      refute status.out_of_sync?
    end

    context 'with last report format' do
      setup do
        status.last_report.stubs(:format).returns('Test')
      end

      test 'is false when formats out of sync is disabled' do
        stub_outofsync_setting(true)
        refute status.out_of_sync?
      end

      test "is true when formats out of sync isn't disbled and it is ouf of sync" do
        stub_outofsync_setting(false)
        status.reported_at = '2015-01-01 00:00:00'
        status.save
        assert status.out_of_sync?
      end

      def stub_outofsync_setting(value)
        Foreman.settings._add('test_out_of_sync_disabled',
          context: :test,
          type: :boolean,
          category: 'Setting',
          full_name: 'Test out of sync',
          description: 'description',
          default: false)
        Setting[:test_out_of_sync_disabled] = value
      end
    end
  end

  test '#refresh! refreshes the date and persists the record' do
    status.expects(:refresh)
    status.refresh!

    assert status.persisted?
  end

  test '#refresh updates date to reported_at of last report' do
    status.reported_at = nil
    status.refresh

    assert_equal report&.reported_at&.to_i, status&.reported_at&.to_i
  end

  test '#relevant? only for hosts with #configuration? true, or a last report, or setting enabled' do
    host.expects(:configuration?).returns(true)
    assert status.relevant?

    host.expects(:configuration?).returns(false)
    status.expects(:last_report).returns(mock)
    assert status.relevant?

    host.expects(:configuration?).returns(false)
    status.expects(:last_report).returns(nil)
    refute status.relevant?

    host.expects(:configuration?).returns(false)
    status.expects(:last_report).returns(nil)
    Setting[:always_show_configuration_status] = true
    assert status.relevant?
  end

  describe "host with puppet report" do
    let(:report) { FactoryBot.create(:host_report, :puppet_format) }

    test 'overwrite puppet_interval as host parameter' do
      if defined? ForemanPuppet
        Setting['puppet_interval'] = 25
      end
      Setting['outofsync_interval'] = 25
      status.reported_at = Time.now.utc - 30.minutes
      assert status.out_of_sync?
      host.params['puppet_interval'] = 35
      refute status.out_of_sync?
    end
  end

  describe "host with applied changes" do
    let(:report) { FactoryBot.create(:host_report, nochange: 0, change: 10, failure: 0) }

    test 'is found via host scoped search' do
      status.save
      assert_equal [host], Host.search_for('report_changes > 0')
      assert_empty Host.search_for('report_changes < 0')
      assert_empty Host.search_for('report_changes = 0')
    end

    test 'is found via host report scoped search' do
      status.save
      assert_equal [report], HostReport.search_for('changes > 0')
      assert_equal [report], HostReport.search_for('changed > 0')
      assert_empty HostReport.search_for('changes < 0')
      assert_empty HostReport.search_for('changed = 0')
    end
  end

  describe "host with failures" do
    let(:report) { FactoryBot.create(:host_report, nochange: 0, change: 0, failure: 10) }

    test 'is found via host scoped search' do
      status.save
      assert_equal [host], Host.search_for('report_failures > 0')
      assert_empty Host.search_for('report_failures < 0')
      assert_empty Host.search_for('report_failures = 0')
    end

    test 'is found via host report scoped search' do
      status.save
      assert_equal [report], HostReport.search_for('failures > 0')
      assert_equal [report], HostReport.search_for('failed > 0')
      assert_empty HostReport.search_for('failures < 0')
      assert_empty HostReport.search_for('failed = 0')
    end
  end

  describe "host with no changes" do
    let(:report) { FactoryBot.create(:host_report, nochange: 10, change: 0, failure: 0) }

    test 'is found via host scoped search' do
      status.save
      assert_equal [host], Host.search_for('report_nochanges > 0')
      assert_empty Host.search_for('report_nochanges < 0')
      assert_empty Host.search_for('report_nochanges = 0')
    end

    test 'is found via host report scoped search' do
      status.save
      assert_equal [report], HostReport.search_for('unchanged > 0')
      assert_equal [report], HostReport.search_for('nochanges > 0')
      assert_empty HostReport.search_for('unchanged < 0')
      assert_empty HostReport.search_for('nochanges = 0')
    end
  end
end
