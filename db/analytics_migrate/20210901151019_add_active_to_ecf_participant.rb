# frozen_string_literal: true

class AddActiveToECFParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participants, :active, :boolean, default: true
  end
end
