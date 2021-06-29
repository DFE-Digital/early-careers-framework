# frozen_string_literal: true

class CreateMentorProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_profile_declarations do |t|
      t.references :mentor_profile, null: false, index: true
      t.timestamps
    end
  end
end
