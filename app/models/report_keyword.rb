class ReportKeyword < ApplicationRecord
  def host_reports
    HostReport.where("report_keyword_ids @> ?", "{#{id}}")
  end

  # This is to simulate has_many :report_keywords relation for scoped_search library to work
  # NOTE: This won't work for any other purpose
  def self.klass
    self
  end

  # Needed for ActiveRecord to simulate ActiveRecord::Associations::CollectionProxy
  def self.macro
    :has_many
  end
end
