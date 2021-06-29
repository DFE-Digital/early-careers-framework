# frozen_string_literal: true

class CreateEarlyCareerTeacherProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :early_career_teacher_profile_declarations do |t|
      t.references :early_career_teacher_profile, null: false, index: { name: :profile_declaration_ect_profiles }
      t.timestamps
    end
  end
end
