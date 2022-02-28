class AddNoInductionToECFParticipantEligibilities < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participant_eligibilities, :no_induction, :boolean
  end
end
