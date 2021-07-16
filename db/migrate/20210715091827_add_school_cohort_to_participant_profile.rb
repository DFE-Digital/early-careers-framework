# frozen_string_literal: true

class AddSchoolCohortToParticipantProfile < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profiles, :school_cohort, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end
