# frozen_string_literal: true

class AddPayableToParticipantDeclaration < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_declarations, :payable, :boolean, default: false
  end
end
