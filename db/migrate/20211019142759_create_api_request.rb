# frozen_string_literal: true

class CreateApiRequest < ActiveRecord::Migration[6.1]
  def change
    create_table :api_requests do |t|
      t.string :request_path
      t.integer :status_code
      t.jsonb :request_headers
      t.jsonb :request_body

      t.jsonb :response_body
      t.string :request_method
      t.jsonb :response_headers

      t.references :cpd_lead_provider, null: true, foreign_key: true, type: :uuid
      t.string :user_description

      t.timestamps
    end
  end
end
