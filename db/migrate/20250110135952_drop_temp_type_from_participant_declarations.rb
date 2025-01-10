# frozen_string_literal: true

class DropTempTypeFromParticipantDeclarations < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :participant_declarations, :temp_type, :string }
  end
end
