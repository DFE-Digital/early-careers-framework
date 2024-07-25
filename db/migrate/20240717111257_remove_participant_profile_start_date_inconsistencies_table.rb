# frozen_string_literal: true

class RemoveParticipantProfileStartDateInconsistenciesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :participant_profile_start_date_inconsistencies
  end
end
