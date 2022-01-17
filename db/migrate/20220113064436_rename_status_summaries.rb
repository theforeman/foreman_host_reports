class RenameStatusSummaries < ActiveRecord::Migration[6.0]
  def change
    remove_column :host_reports, :applied, :integer
    remove_column :host_reports, :pending, :integer
    remove_column :host_reports, :other, :integer
    remove_column :host_reports, :failed, :integer

    add_column :host_reports, :change, :integer, default: 0
    add_column :host_reports, :nochange, :integer, default: 0
    add_column :host_reports, :failure, :integer, default: 0
  end
end
