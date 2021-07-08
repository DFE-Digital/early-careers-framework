# frozen_string_literal: true

class MoveLpTokens < ActiveRecord::Migration[6.1]
  def change
    LeadProviderApiToken.all.each do |token|
      token.update!(cpd_lead_provider: token.lead_provider.cpd_lead_provider)
    end
  end
end
