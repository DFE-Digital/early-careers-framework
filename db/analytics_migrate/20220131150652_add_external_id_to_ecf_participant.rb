# frozen_string_literal: true

class AddExternalIdToECFParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participants, :external_id, :string
  end
end
