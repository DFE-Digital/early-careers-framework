# frozen_string_literal: true

class AddScheduleToParticipantProfile < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profiles, :schedule, index: { algorithm: :concurrently }
  end
end
