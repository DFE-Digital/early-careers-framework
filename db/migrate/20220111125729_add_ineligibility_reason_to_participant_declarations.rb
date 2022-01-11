# frozen_string_literal: true

class AddIneligibilityReasonToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_enum :state_reason_type, %w[duplicate]
  end
end
