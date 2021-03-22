# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_partners
#
#  id           :uuid             not null, primary key
#  discarded_at :datetime
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_delivery_partners_on_discarded_at  (discarded_at)
#
class DeliveryPartner < DiscardableRecord
  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships

  after_discard do
    provider_relationships.discard_all
  end

  def cohorts_with_provider(lead_provider)
    provider_relationships.joins(:cohort).includes(:cohort).where(lead_provider: lead_provider).map(&:cohort)
  end
end
