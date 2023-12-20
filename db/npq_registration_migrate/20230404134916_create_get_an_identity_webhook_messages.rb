class CreateGetAnIdentityWebhookMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :get_an_identity_webhook_messages do |t|
      t.jsonb :raw
      t.jsonb :message
      t.string :message_id
      t.string :message_type
      t.string :status, default: "pending"
      t.string :status_comment

      t.datetime :sent_at
      t.datetime :processed_at

      t.timestamps
    end
  end
end
