require 'test_plugin_helper'

class Api::V2::HostReportsControllerTest < ActionController::TestCase
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
          status: 0
        },
      }, session: set_session_user
      assert_response :success
    end

    def test_create_invalid
      User.current = nil
      post :create, params: { host_report: { body: report_body } }, session: set_session_user
      assert_response :unprocessable_entity
    end

    # TODO: should we allow duplicates? If no, what's the best way to determine one?
    # def test_create_duplicate
    #   User.current = nil
    #   post :create, params: { :host_report => report_body }, session: set_session_user
    #   assert_response :success
    #   post :create, params: { :host_report => report_body }, session: set_session_user
    #   assert_response :unprocessable_entity
    # end

    # TODO: all the tests below are related to smart proxy auth. Should we behave the same?
    # test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to create a report' do
    #   Setting[:restrict_registered_smart_proxies] = false
    #   SETTINGS[:require_ssl] = false
    #
    #   Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    #   post :create, params: { :host_report => report_body }
    #   assert_nil @controller.detected_proxy
    #   assert_response :created
    # end
    #
    # test 'hosts with a registered smart proxy on should create a report successfully' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = false
    #
    #   stub_smart_proxy_v2_features
    #   proxy = smart_proxies(:puppetmaster)
    #   as_admin { proxy.update_attribute(:url, 'http://configreports.foreman') }
    #   host = URI.parse(proxy.url).host
    #   Resolv.any_instance.stubs(:getnames).returns([host])
    #   post :create, params: { :host_report => report_body }
    #   assert_equal proxy, @controller.detected_proxy
    #   assert_response :created
    # end
    #
    # test 'hosts without a registered smart proxy on should not be able to create a report' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = false
    #
    #   Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    #   post :create, params: { :host_report => report_body }
    #   assert_response :forbidden
    # end
    #
    # test 'hosts with a registered smart proxy and SSL cert should create a report successfully' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = true
    #
    #   @request.env['HTTPS'] = 'on'
    #   @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    #   @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    #   post :create, params: { :host_report => report_body }
    #   assert_response :created
    # end
    #
    # test 'hosts without a registered smart proxy but with an SSL cert should not be able to create a report' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = true
    #
    #   @request.env['HTTPS'] = 'on'
    #   @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
    #   @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    #   post :create, params: { :host_report => report_body }
    #   assert_response :forbidden
    # end
    #
    # test 'hosts with an unverified SSL cert should not be able to create a report' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = true
    #
    #   @request.env['HTTPS'] = 'on'
    #   @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    #   @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    #   post :create, params: { :host_report => report_body }
    #   assert_response :forbidden
    # end
    #
    # test 'when "require_ssl_smart_proxies" and "require_ssl" are true, HTTP requests should not be able to create a report' do
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = true
    #   SETTINGS[:require_ssl] = true
    #
    #   Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    #   post :create, params: { :host_report => report_body }
    #   assert_response :forbidden
    # end
    #
    # test 'when "require_ssl_smart_proxies" is true and "require_ssl" is false, HTTP requests should be able to create reports' do
    #   # since require_ssl_smart_proxies is only applicable to HTTPS connections, both should be set
    #   Setting[:restrict_registered_smart_proxies] = true
    #   Setting[:require_ssl_smart_proxies] = true
    #   SETTINGS[:require_ssl] = false
    #
    #   Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    #   post :create, params: { :host_report => report_body }
    #   assert_response :created
    # end
  end

  test 'should get index' do
    FactoryBot.create(:host_report)
    get :index
    assert_response :success
    assert_not_nil assigns(:host_reports)
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
      assert_not_nil assigns(:host_reports)
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

  # TODO: update routes to support /hosts/:id/host_reports
  # test 'should get reports for given host only' do
  #   report = FactoryBot.create(:host_report)
  #   get :index, params: { host_id: report.host.to_param }
  #   assert_response :success
  #   assert_not_nil assigns(:host_reports)
  #   reports = ActiveSupport::JSON.decode(@response.body)
  #   refute_empty reports['results']
  #   assert_equal 1, reports['results'].count
  # end
  # TODO: update routes to support /hosts/:id/host_reports
  # test "should return empty result for host with no reports" do
  #   host = FactoryBot.create(:host)
  #   get :index, params: { :host_id => host.to_param }
  #   assert_response :success
  #   assert_not_nil assigns(:host_reports)
  #   reports = ActiveSupport::JSON.decode(@response.body)
  #   assert reports['results'].empty?
  #   assert_equal 0, reports['results'].count
  # end
end