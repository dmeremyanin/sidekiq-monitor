class CreateSidekiqMonitorEvents < ActiveRecord::Migration
  def change
    create_table :sidekiq_monitor_events do |t|
      t.string   :revision,     null: false
      t.string   :worker_class, null: false
      t.string   :queue,        null: false
      t.string   :jid,          null: false
      t.integer  :retry_count
      t.text     :args
      t.text     :exception
      t.datetime :started_at
      t.float    :runtime
      t.timestamps
    end

    add_index :sidekiq_monitor_events, :jid, unique: true
  end
end
