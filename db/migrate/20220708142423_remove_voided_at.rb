# frozen_string_literal: true

class RemoveVoidedAt < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :participant_declarations, :voided_at, :datetime
    end
  end
end
