# frozen_string_literal: true

class AddUniqueIndexToParticipantProfileStartDateInconsistencies < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :participant_profile_start_date_inconsistencies, :participant_profile_id
    add_index :participant_profile_start_date_inconsistencies, :participant_profile_id, unique: true, algorithm: :concurrently
  end
end
