# frozen_string_literal: true

class AddUpliftToEarlyCareerTeacherProfile < ActiveRecord::Migration[6.1]
  def change
    change_table(:early_career_teacher_profiles, bulk: true) do |table|
      table.column :sparsity_uplift, :boolean, null: false, default: false
      table.column :pupil_premium_uplift, :boolean, null: false, default: false
    end
  end
end
