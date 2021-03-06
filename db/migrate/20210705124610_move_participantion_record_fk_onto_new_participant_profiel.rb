# frozen_string_literal: true

class MoveParticipantionRecordFkOntoNewParticipantProfiel < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :participation_records, :early_career_teacher_profiles
    add_foreign_key :participation_records, :participant_profiles, column: :early_career_teacher_profile_id, validate: false
  end
end
