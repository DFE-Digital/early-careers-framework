# frozen_string_literal: true

class AddUpliftToEarlyCareerTeacherProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :early_career_teacher_profiles, :uplift, :boolean, null: false, default: false
  end
end
