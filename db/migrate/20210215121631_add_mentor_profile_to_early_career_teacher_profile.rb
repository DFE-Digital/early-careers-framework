# frozen_string_literal: true

class AddMentorProfileToEarlyCareerTeacherProfile < ActiveRecord::Migration[6.1]
  def change
    add_reference :early_career_teacher_profiles, :mentor_profile, null: true, foreign_key: true
  end
end
