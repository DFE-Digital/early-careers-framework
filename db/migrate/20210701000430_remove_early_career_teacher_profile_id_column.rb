# frozen_string_literal: true

class RemoveEarlyCareerTeacherProfileIdColumn < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :participant_declarations, :early_career_teacher_profile_id, :uuid, null: true }
  end
end
