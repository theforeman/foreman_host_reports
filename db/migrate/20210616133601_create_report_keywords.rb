# rubocop:disable Rails/CreateTableWithTimestamps
class CreateReportKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :report_keywords do |t|
      t.string :name, null: false, index: { unique: true }
    end

    create_table :host_reports_report_keywords, id: false do |t|
      t.belongs_to :host_report
      t.belongs_to :report_keyword
      t.index %i[host_report_id report_keyword_id], unique: true, name: 'index_on_host_report_report_keyword'
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
