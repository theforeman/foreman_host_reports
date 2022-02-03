# frozen_string_literal: true

class HostReportsController < ::ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  def index
    respond_to do |format|
      format.html do
        render '/react/index'
      end

      format.json do
        reports = resource_base_search_and_page
        render json: {
          itemCount: reports.count,
          reports: reports.map do |r|
            r.attributes.except('body').merge(
              keywords: r.report_keywords.map(&:name),
              can_delete: can_delete?(r),
              can_view: can_view?(r),
              status: r.status
            )
          end,
        }, status: :ok
      end
    end
  end

  def show
    @host_report = resource_scope.find(params[:id])

    return not_found unless @host_report

    respond_to do |format|
      format.html do
        render '/react/index'
      end
      format.json do
        render json: {
          host_report: {
            id: @host_report.id,
            body: JSON.parse(@host_report.body),
            format: @host_report.format,
            host: {
              id: @host_report.host.id,
              name: @host_report.host.name,
            },
            proxy: {
              id: @host_report.proxy&.id,
              name: @host_report.proxy&.name,
            },
            reported_at: @host_report.reported_at,
          },
          permissions: {
            can_delete: can_delete?(@host_report),
            can_view: can_view?(@host_report),
          },
        }, status: :ok
      end
    end
  end

  private

  def resource_scope(options = {})
    options[:permission] = :view_host_reports
    super(options).my_reports
  end

  def can_delete?(report)
    authorized_for(auth_object: report, authorizer: authorizer, permission: "destroy_#{controller_permission}")
  end

  def can_view?(report)
    authorized_for(auth_object: report, authorizer: authorizer, permission: "view_#{controller_permission}")
  end
end
