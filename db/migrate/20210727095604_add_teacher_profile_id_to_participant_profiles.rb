# frozen_string_literal: true

class AddTeacherProfileIdToParticipantProfiles < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profiles, :teacher_profile, index: { algorithm: :concurrently }
  end
end
