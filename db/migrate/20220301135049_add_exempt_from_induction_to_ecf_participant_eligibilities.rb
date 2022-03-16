# frozen_string_literal: true

class AddExemptFromInductionToECFParticipantEligibilities < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participant_eligibilities, :exempt_from_induction, :boolean
  end
end
