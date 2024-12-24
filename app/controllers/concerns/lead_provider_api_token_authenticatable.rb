# frozen_string_literal: true

module LeadProviderApiTokenAuthenticatable
  extend ActiveSupport::Concern
  include ApiTokenAuthenticatable

private

  def access_scope
    LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
  end
end
