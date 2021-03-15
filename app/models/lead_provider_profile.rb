# frozen_string_literal: true

class LeadProviderProfile < BaseProfile
  belongs_to :user
  belongs_to :lead_provider
end
