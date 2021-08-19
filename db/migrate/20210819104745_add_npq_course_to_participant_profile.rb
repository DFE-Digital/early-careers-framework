# frozen_string_literal: true

class AddNPQCourseToParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :participant_profiles, :npq_course, null: true, foreign_key: true
    end
  end
end
