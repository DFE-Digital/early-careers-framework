# frozen_string_literal: true

class ProviderRelationship < DiscardableRecord
  has_paper_trail

  belongs_to :cohort
  belongs_to :lead_provider
  belongs_to :delivery_partner
end
