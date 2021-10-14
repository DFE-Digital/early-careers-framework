# frozen_string_literal: true

class AddDifferentTrnToECFParticipantEligibility < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participant_eligibilities, :different_trn, :boolean
  end
end
