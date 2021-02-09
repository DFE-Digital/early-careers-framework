# frozen_string_literal: true

class ProviderRelationship < ApplicationRecord
  belongs_to :cohort
  belongs_to :lead_provider
  belongs_to :delivery_partner
end
