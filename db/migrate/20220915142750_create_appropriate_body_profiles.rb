# frozen_string_literal: true

class CreateAppropriateBodyProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :appropriate_body_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :appropriate_body, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
