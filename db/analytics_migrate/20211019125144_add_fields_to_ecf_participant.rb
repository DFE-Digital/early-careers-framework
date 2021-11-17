# frozen_string_literal: true

class AddFieldsToECFParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participants, :training_status, :string
    add_column :ecf_participants, :sparsity, :boolean
    add_column :ecf_participants, :pupil_premium, :boolean
  end
end
