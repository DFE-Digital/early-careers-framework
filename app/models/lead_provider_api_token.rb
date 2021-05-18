# frozen_string_literal: true

class LeadProviderApiToken < ApiToken
  belongs_to :lead_provider

  def owner
    lead_provider
  end
end
