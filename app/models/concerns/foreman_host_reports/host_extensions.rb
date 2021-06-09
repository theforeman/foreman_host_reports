module ForemanHostReports
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_many :host_reports, foreign_key: :host_id, class_name: 'HostReport', inverse_of: :host, dependent: :destroy
    end
  end
end
