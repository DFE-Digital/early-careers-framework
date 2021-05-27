# frozen_string_literal: true

class CreateMentorProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :core_induction_programme, null: true, foreign_key: true, type: :uuid, index: { name: :index_mentor_profiles_on_core_induction_programme_id }
      t.references :cohort, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_reference :early_career_teacher_profiles, :mentor_profile, null: true, foreign_key: true
  end
end
