# frozen_string_literal: true

class AddInductionStartDateToParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :induction_start_date, :date
  end
end
