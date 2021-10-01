# frozen_string_literal: true

class AddReasonToECFParticipantEligibilities < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participant_eligibilities, :reason, :string, null: false, default: "none"
  end
end
