# frozen_string_literal: true

class HostReportsController < ::ApplicationController
  include Foreman::Controller::AutoCompleteSearch

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
            can_delete: authorized_for(auth_object: @host_report, authorizer: authorizer, permission: "destroy_#{controller_permission}"),
            can_view: authorized_for(auth_object: @host_report, authorizer: authorizer, permission: "view_#{controller_permission}"),
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
end
