class AddStateToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_declarations, :state, :string, null: false, default: "submitted"
  end
end
