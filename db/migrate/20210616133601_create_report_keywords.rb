# rubocop:disable Rails/CreateTableWithTimestamps
class CreateReportKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :report_keywords do |t|
      t.string :name, null: false, index: { unique: true }
    end

    add_column :host_reports, :report_keyword_ids, :integer, array: true, default: []
    add_index :host_reports, :report_keyword_ids, using: 'gin'
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
