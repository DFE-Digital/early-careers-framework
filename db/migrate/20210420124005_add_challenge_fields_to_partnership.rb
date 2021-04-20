# frozen_string_literal: true

class AddChallengeFieldsToPartnership < ActiveRecord::Migration[6.1]
  def change
    change_table :partnerships, bulk: true do
      add_column :partnerships, :challenged_at, :datetime
      add_column :partnerships, :challenge_reason, :string
    end
  end
end
