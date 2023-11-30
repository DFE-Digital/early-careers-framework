# frozen_string_literal: true

class CreateSupportQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :support_queries do |t|
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.integer :zendesk_ticket_id, null: true

      t.string :subject, null: false
      t.string :message, null: false

      t.jsonb :additional_information, default: {}, null: false

      t.timestamps
    end
  end
end
