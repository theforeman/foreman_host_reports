module ForemanHostReports
  module SmartProxyExtensions
    extend ActiveSupport::Concern

    included do
      has_many :host_reports, foreign_key: :proxy_id, class_name: 'HostReport', inverse_of: :proxy, dependent: :destroy
    end
  end
end
