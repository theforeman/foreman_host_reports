require 'test_plugin_helper'

class ForemanHostReportsTest < ActiveSupport::TestCase
  test 'should find host reports by keyword' do
    report = FactoryBot.create(:host_report, :with_keyword)
    result = HostReport.search_for("keyword= HasError").pluck(:id)
    assert_include result, report.id
  end
end
