# frozen_string_literal: true

class AddParticipantProfileToTeacherProfileFk < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_profiles, :teacher_profiles, validate: false
  end
end
