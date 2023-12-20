class CreateEcfSyncRequestLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_sync_request_logs do |t|
      t.integer :syncable_id, null: false
      t.string :syncable_type, null: false
      t.string :status, null: false
      t.string :sync_type, null: false
      t.jsonb :error_messages, default: []
      t.jsonb :response_body

      t.index(%i[syncable_id syncable_type])

      t.timestamps
    end
  end
end
