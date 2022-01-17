require 'test_plugin_helper'

class Api::V2::HostReportsControllerTest < ActionController::TestCase
  setup do
    @proxy = FactoryBot.create(:smart_proxy,
      url: "http://reports.foreman.example.com",
      features: [FactoryBot.create(:feature, name: 'Reports')])
    Resolv.any_instance.stubs(:getnames).returns([URI.parse(@proxy.url).host])
    SmartProxy.any_instance.stubs(:with_features).returns([@proxy])
    ProxyAPI::V2::Features.any_instance.stubs(:features).returns({ "reports" => { "state" => "running" } })
  end

  context 'when user does not have permission to view hosts' do
    let :host_report do
      as_admin { FactoryBot.create(:host_report) }
    end

    setup { setup_user('view', 'host_reports') }

    test 'cannot view any reports' do
      get :show, params: { id: host_report.id }, session: set_session_user.merge(user: User.current.id)
      assert_response :not_found
    end

    test 'cannot delete host reports' do
      setup_user 'destroy', 'host_reports'
      delete :destroy, params: { id: host_report.id }, session: set_session_user.merge(user: User.current.id)
      assert_response :not_found
    end
  end

  describe 'Non Admin User' do
    def setup
      User.current = users(:one) # use an unprivileged user, not apiadmin
    end

    def report_body
      @report_body ||= read_report('foreman-web.json')
    end

    let :host do
      as_admin { FactoryBot.create(:host) }
    end

    def test_create_valid
      User.current = nil
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }, session: set_session_user
      assert_response :success
    end

    def test_create_invalid
      User.current = nil
      post :create, params: { host_report: { body: report_body } }, session: set_session_user
      assert_response :unprocessable_entity
    end

    test 'store statuses' do
      User.current = nil
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          keywords: %w[HasError HasFailedResource],
          change: 1, nochange: 2, failure: 3
        },
      }, session: set_session_user
      report = ActiveSupport::JSON.decode(@response.body)
      assert_response :created
      assert_equal 1, report['change']
      assert_equal 2, report['nochange']
      assert_equal 3, report['failure']
    end

    test 'assign keywords' do
      User.current = nil
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          keywords: %w[HasError HasFailedResource],
          change: 1, nochange: 2, failure: 3
        },
      }, session: set_session_user
      report = ActiveSupport::JSON.decode(@response.body)
      assert_response :created
      refute_empty report['keywords']
    end

    test 're-use existing keywords' do
      User.current = nil
      assert_difference('ReportKeyword.count', 2) do
        post :create, params: {
          host_report: {
            host: host.name, body: report_body, reported_at: Time.current,
            keywords: %w[HasError HasFailedResource],
            change: 1, nochange: 2, failure: 3
          },
        }, session: set_session_user

        post :create, params: {
          host_report: {
            host: host.name, body: report_body, reported_at: Time.current,
            keywords: %w[HasError HasFailedResource],
            change: 1, nochange: 2, failure: 3
          },
        }, session: set_session_user
      end
    end

    test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = false
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_nil @controller.detected_proxy
      assert_response :created
    end

    test 'hosts with a registered smart proxy and SSL cert should create a report successfully' do
      Setting[:restrict_registered_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=reports.foreman.example.com'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_response :created
    end

    test 'hosts without a registered smart proxy but with an SSL cert should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_response :forbidden
    end

    test 'hosts with an unverified SSL cert should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_response :forbidden
    end

    test 'when "require_ssl" is true, HTTP requests should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true
      SETTINGS[:require_ssl] = true

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_response :redirect
    end

    test 'when "require_ssl" is false, HTTP requests should be able to create reports' do
      Setting[:restrict_registered_smart_proxies] = true
      SETTINGS[:require_ssl] = false

      post :create, params: {
        host_report: {
          host: host.name, body: report_body, reported_at: Time.current,
          change: 1, nochange: 2, failure: 3
        },
      }
      assert_response :created
    end
  end

  test 'should get index' do
    FactoryBot.create(:host_report)
    get :index
    assert_response :success
    refute_nil assigns(:host_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    refute_empty reports['results']
  end

  context 'with organization given' do
    let(:host_report_org) { Organization.first }
    let(:host_report_loc) { Location.first }
    let(:reporting_host) do
      FactoryBot.create(:host, location: host_report_loc, organization: host_report_org)
    end
    let(:host_report) do
      FactoryBot.create(:host_report, host: reporting_host)
    end

    test 'should get host reports in organization' do
      host_report.save!
      get :index, params: { organization_id: host_report_org.id }
      assert_response :success
      refute_nil assigns(:host_reports)
      reports = ActiveSupport::JSON.decode(@response.body)
      refute_empty reports['results']
    end
  end

  test 'should show individual record' do
    report = FactoryBot.create(:host_report)
    get :show, params: { id: report.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test 'should destroy report' do
    report = FactoryBot.create(:host_report)
    assert_difference('HostReport.count', -1) do
      delete :destroy, params: { id: report.to_param }
    end
    assert_response :success
    refute HostReport.unscoped.find_by(id: report.id)
  end

  test 'should get reports for given host only' do
    report = FactoryBot.create(:host_report)
    get :index, params: { host_id: report.host.id }
    assert_response :success
    refute_nil assigns(:host_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    refute_empty reports['results']
    assert_equal 1, reports['results'].count
  end

  test 'should return empty result for host with no reports' do
    host = FactoryBot.create(:host)
    get :index, params: { host_id: host.to_param }
    assert_response :success
    refute_nil assigns(:host_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert_empty reports['results']
    assert_equal 0, reports['results'].count
  end
end
