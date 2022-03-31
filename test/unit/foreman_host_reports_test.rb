require 'test_plugin_helper'

class ForemanHostReportsTest < ActiveSupport::TestCase
  test 'should find host reports by keyword' do
    report = FactoryBot.create(:host_report, :with_keyword)
    result = HostReport.search_for("keyword= HasError").pluck(:id)
    assert_include result, report.id
  end

  describe 'send failure mail' do
    setup do
      ActionMailer::Base.deliveries = []
    end

    let(:ansible_report_with_failure) { FactoryBot.create(:host_report, :ansible_format, :with_failure, body: "{\"format\":\"ansible\",\"id\":\"bd9ae179-a52c-4177-b81e-b8a54968895c\",\"host\":\"report.example.com\",\"proxy\":\"localhost\",\"reported_at\":\"2021-10-08T13:49:52.402311\",\"reported_at_proxy\":\"2022-03-29 14:05:14 UTC\",\"results\":[{\"failed\":false,\"result\":{\"_ansible_no_log\":false,\"changed\":false,\"invocation\":{\"module_args\":{\"allow_downgrade\":false,\"autoremove\":false,\"bugfix\":false,\"disable_gpg_check\":false,\"download_only\":false,\"install_repoquery\":true,\"install_weak_deps\":true,\"installroot\":\"/\",\"lock_timeout\":30,\"name\":[\"neovim\"],\"security\":false,\"skip_broken\":false,\"state\":\"present\",\"update_cache\":false,\"update_only\":false,\"validate_certs\":true}},\"msg\":\"Nothing to do\",\"rc\":0},\"task\":{\"action\":\"ansible.builtin.package\",\"any_errors_fatal\":false,\"async\":0,\"async_val\":0,\"become\":false,\"become_method\":\"sudo\",\"check_mode\":false,\"connection\":\"smart\",\"delay\":5,\"diff\":false,\"finalized\":true,\"name\":\"\",\"poll\":15,\"retries\":3,\"squashed\":true,\"throttle\":0,\"uuid\":\"1c697a0b-ae03-f522-0c2f-000000000009\"},\"level\":\"info\",\"friendly_message\":\"Package(s) neovim are present\"}],\"summary\":{\"foreman\":{\"change\":0,\"nochange\":1,\"failure\":0},\"native\":{\"changed\":0,\"failures\":0,\"ignored\":0,\"ok\":0,\"rescued\":0,\"skipped\":0,\"unreachable\":0}},\"keywords\":[],\"telemetry\":{\"parse\":0.06191397551447153,\"build_facts\":0.002874992787837982,\"process_results\":0.012931006494909525},\"check_mode\":false}") }
    let(:puppet_report_with_failure) { FactoryBot.create(:host_report, :puppet_format, :with_failure) }

    test 'call #send_failure_mail on commit' do
      ansible_report_with_failure.expects(:send_failure_mail)
      ansible_report_with_failure.run_callbacks(:commit)
    end

    test 'should send an email when a report in ansible format has failed' do
    end

    test 'should send an email when a report in puppet format has failed' do
    end
  end
end
