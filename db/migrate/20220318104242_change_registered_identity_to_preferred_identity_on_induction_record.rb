# frozen_string_literal: true

class ChangeRegisteredIdentityToPreferredIdentityOnInductionRecord < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      rename_column :induction_records, :registered_identity_id, :preferred_identity_id
    end
  end
end
