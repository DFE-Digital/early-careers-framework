# frozen_string_literal: true

class AddPreviousCohortAndReasonToParticipantProfile < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profiles, :previous_cohort, index: { algorithm: :concurrently }

    add_column :participant_profiles, :reason_for_new_cohort, :string
  end
end
