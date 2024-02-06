# frozen_string_literal: true

class AddMentorCompletionToParticipantProfile < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :participant_profiles, bulk: true do |t|
        t.date :mentor_completion_date
        t.string :mentor_completion_reason
      end
    end
  end
end
