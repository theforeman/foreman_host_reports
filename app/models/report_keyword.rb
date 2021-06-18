class ReportKeyword < ApplicationRecord
  has_and_belongs_to_many :host_reports
end
