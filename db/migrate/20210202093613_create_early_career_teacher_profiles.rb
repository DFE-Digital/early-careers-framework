# frozen_string_literal: true

class CreateEarlyCareerTeacherProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :early_career_teacher_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :core_induction_programme, null: true, foreign_key: true, type: :uuid, index: { name: :index_ect_profiles_on_core_induction_programme_id }
      t.references :cohort, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
