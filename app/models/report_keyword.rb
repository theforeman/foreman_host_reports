class ReportKeyword < ApplicationRecord
  has_and_belongs_to_many :host_reports

  validates :name, uniqueness: true, presence: true
end
