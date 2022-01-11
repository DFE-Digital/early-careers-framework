class AddIneligibilityReasonToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_enum :ineligibility_reason_type, %w[duplicate]
  end
end
