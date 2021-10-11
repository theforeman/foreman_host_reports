class ChangeStatusColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :host_reports, :status, :bigint

    add_column :host_reports, :applied, :integer, default: 0
    add_column :host_reports, :failed, :integer, default: 0
    add_column :host_reports, :pending, :integer, default: 0
    add_column :host_reports, :other, :integer, default: 0
  end
end
