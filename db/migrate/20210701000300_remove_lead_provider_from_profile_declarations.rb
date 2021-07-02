# frozen_string_literal: true

class RemoveLeadProviderFromProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :profile_declarations, :lead_provider_id, :uuid }
  end
end
