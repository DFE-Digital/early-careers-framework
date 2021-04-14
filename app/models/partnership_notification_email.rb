# frozen_string_literal: true

class PartnershipNotificationEmail < ApplicationRecord
  belongs_to :partnership
  delegate :school, to: :partnership, allow_nil: false
  delegate :lead_provider, to: :partnership, allow_nil: false
  delegate :delivery_partner, to: :partnership, allow_nil: true
  delegate :cohort, to: :partnership, allow_nil: false
end
