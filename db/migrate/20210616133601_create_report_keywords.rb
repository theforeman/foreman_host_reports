# rubocop:disable Rails/CreateTableWithTimestamps
class CreateReportKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :report_keywords do |t|
      t.string :name, null: false, index: { unique: true }
    end

    create_table :host_reports_report_keywords, id: false do |t|
      # belongs_to defaults to index
      t.belongs_to :host_report
      t.belongs_to :report_keyword
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
