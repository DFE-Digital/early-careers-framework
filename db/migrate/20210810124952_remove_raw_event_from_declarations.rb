# frozen_string_literal: true

class RemoveRawEventFromDeclarations < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :participant_declarations, :raw_event, type: :jsonb }
  end
end
