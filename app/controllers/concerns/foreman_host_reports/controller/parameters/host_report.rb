# frozen_string_literal: true

module ForemanHostReports
  module Controller
    module Parameters
      module HostReport
        extend ActiveSupport::Concern

        class_methods do
          def host_report_params_filter
            Foreman::ParameterFilter.new(::HostReport).tap do |filter|
              # body is permitted in controller
              filter.permit :format, :version, :host, :proxy, :reported_at,
                :proxy_id, :host_id, :change, :nochange, :failure
              filter.permit :keywords => []
            end
          end
        end

        def host_report_params
          self.class.host_report_params_filter.filter_params(params, parameter_filter_context)
        end
      end
    end
  end
end
