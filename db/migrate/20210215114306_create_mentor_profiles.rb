# frozen_string_literal: true

class CreateMentorProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
