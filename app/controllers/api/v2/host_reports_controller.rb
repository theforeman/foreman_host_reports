# frozen_string_literal: true

module Api
  module V2
    class HostReportsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::CsvResponder
      include Foreman::Controller::SmartProxyAuth
      include ForemanHostReports::Controller::Parameters::HostReport

      before_action :find_resource, only: %i[destroy]
      before_action :resolve_ids, only: %i[create]

      add_smart_proxy_filters :create, features: ['Reports']

      api :GET, '/host_reports/', N_('List host reports')
      param_group :search_and_pagination, ::Api::V2::BaseController
      param :host_id, :identifier, required: false, desc: N_('If provided, filters reports by the host')
      add_scoped_search_description_for(HostReport)
      def index
        options = {}
        options.update(host_id: params[:host_id]) if params[:host_id]
        @host_reports = resource_scope_for_index(options)
      end

      api :GET, '/host_report/:id', N_('Show host report details')
      param :id, :identifier, required: true
      def show
        @host_report = resource_scope.find(params[:id])
      end

      def_param_group :host_report do
        param :host_report, Hash, action_aware: true, required: true do
          param :host, String, required: true, desc: N_("Hostname of the report's host origin")
          param :format, HostReport.formats.keys, required: false, desc: N_('Format of the report, e.g. Ansible')
          param :reported_at, String, required: true, desc: N_('UTC time of the report')
          param :applied, Integer, required: false, desc: N_('Number of applied resources or tasks')
          param :failed, Integer, required: false, desc: N_('Number of failed resources or tasks')
          param :pending, Integer, required: false, desc: N_('Number of pending resources or tasks')
          param :other, Integer, required: false, desc: N_('Number of other resources or tasks')
          param :body, String, required: true, desc: N_('String with JSON formatted body of the report')
          param :proxy, String, required: false, desc: N_('Hostname of the proxy processed the report')
          param :keywords, Array, of: String, required: false, desc: N_('A list of keywords to associate with the report for better searching')
        end
      end

      api :POST, '/host_report/', N_('Create a host report')
      param_group :host_report, as: :create

      def create
        params[:host_report].delete(:version)
        the_body = params[:host_report].delete(:body)
        if the_body && !the_body.is_a?(String)
          logger.warn "Report body not as a string, serializing JSON"
          the_body = JSON.pretty_generate(the_body)
        end
        keywords = params[:host_report].delete(:keywords)
        @host_report = HostReport.new(host_report_params.merge(body: the_body))
        if keywords.present?
          keywords_to_insert = keywords.each_with_object([]) do |n, ks|
            ks << { name: n }
          end
          ReportKeyword.upsert_all(keywords_to_insert, unique_by: :name)
          @host_report.report_keyword_ids = ReportKeyword.where(name: keywords).distinct.pluck(:id)
        end
        result = @host_report.save
        @host_report.body = nil
        process_response result
      end

      api :DELETE, '/host_reports/:id', N_('Delete a host report')
      param :id, :identifier, required: true
      def destroy
        process_response @host_report.destroy
      end

      api :GET, '/host_reports/export', N_('Export host reports in a CSV file')
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(HostReport)
      def export
        params[:per_page] = 'all'
        @host_reports = resource_scope_for_index.preload(:host, :proxy)
        csv_response(@host_reports)
      end

      private

      def resolve_ids
        hostname = params[:host_report].delete(:host)
        proxyname = params[:host_report].delete(:proxy)
        params[:host_report][:host_id] ||= Host.find_by(name: hostname)&.id
        params[:host_report][:proxy_id] ||= SmartProxy.unscoped.find_by(name: proxyname)&.id
      end

      def resource_scope(options = {})
        options[:permission] = :view_host_reports
        super(options).includes(:host, :proxy).my_reports
      end
    end
  end
end
