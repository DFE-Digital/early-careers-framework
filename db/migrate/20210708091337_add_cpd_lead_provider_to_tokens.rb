# frozen_string_literal: true

class AddCpdLeadProviderToTokens < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :api_tokens, :cpd_lead_provider, foreign_key: true
    end
  end
end
