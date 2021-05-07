
class AddHostReports < ActiveRecord::Migration[6.0]
  def change
    create_table :fhr_reports do |t|
      # Host reference, b-tree index.
      t.integer "host_id", null: false

      # Smart proxy which processed and uploaded, no index.
      t.integer "proxy_id"
      
      # Explicit timestamp, replaces Rails timestamps, b-tree descending index.
      t.datetime "reported_at", null: false

      # Use StatusCalculator to store arbitrary amount of counters in this
      # bit array (e.g. info, debug, error, fatal messages). Each report
      # implementation decides how to use this bitfield. No index.
      t.bigint "status"

      # Report contents, usually in JSON format depending on implementation.
      # Text field is by default compressed and not searchable, use
      # ReportKeyword model for searching. Other formats like JSON/JSONB were
      # considered but this appears to be the fastest option. No index.
      t.text "body"

      # Report type "enum", integer is faster and smaller than varchar.
      # No index since cardinality is very low (1-3 effectively)
      t.integer "format", default: 0, null: false

      # Indices. Keep it at the bare minimum, this model should be optimized
      # for updates not for reads.
      t.index "host_id"
      t.index "reported_at", order: { reported_at: :desc }
    end
  end
end

