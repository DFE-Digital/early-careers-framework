# frozen_string_literal: true

class RenameParticipantDeclarationOutcomes < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      rename_table :participant_declaration_outcomes, :participant_outcomes
    end
  end
end
