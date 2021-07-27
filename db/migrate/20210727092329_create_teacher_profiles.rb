# frozen_string_literal: true

class CreateTeacherProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :teacher_profiles, id: :uuid do |t|
      t.string :trn
      t.references :school, index: true, foreign_key: true, null: true
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
