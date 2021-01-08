# frozen_string_literal: true

class CreateAdminProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
