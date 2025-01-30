# frozen_string_literal: true

class RemoveNPQCourseIdFromParticipantProfiles < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :participant_profiles, :npq_course_id, :integer }
  end
end

