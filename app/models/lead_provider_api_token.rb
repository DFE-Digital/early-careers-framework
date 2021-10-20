# frozen_string_literal: true

class LeadProviderApiToken < ApiToken
  belongs_to :lead_provider, optional: true
  belongs_to :cpd_lead_provider, optional: true

  def owner
    cpd_lead_provider
  end

  def owner_description
    "CPD lead provider: #{cpd_lead_provider.name}"
  end
end
