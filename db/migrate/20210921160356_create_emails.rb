# frozen_string_literal: true

class CreateEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :emails, id: :uuid do |t|
      t.string :from, nil: false
      t.string :to, nil: false, array: true
      t.uuid :template_id
      t.integer :template_version
      t.string :uri
      t.jsonb :personalisation

      t.timestamps
    end
  end
end
