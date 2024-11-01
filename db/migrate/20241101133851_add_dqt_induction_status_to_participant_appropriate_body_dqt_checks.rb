# frozen_string_literal: true

class AddDQTInductionStatusToParticipantAppropriateBodyDQTChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :participant_appropriate_body_dqt_checks, :dqt_induction_status, :string
  end
end
