# frozen_string_literal: true

class CreateApiRequestAudits < ActiveRecord::Migration[6.1]
  def change
    create_table :api_request_audits do |t|
      t.string :path, null: true
      t.jsonb :body, null: true

      t.timestamps
    end
  end
end
