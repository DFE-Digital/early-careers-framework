# frozen_string_literal: true

# == Schema Information
#
# Table name: provider_relationships
#
#  id                  :uuid             not null, primary key
#  discarded_at        :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cohort_id           :uuid             not null
#  delivery_partner_id :uuid             not null
#  lead_provider_id    :uuid             not null
#
# Indexes
#
#  index_provider_relationships_on_cohort_id            (cohort_id)
#  index_provider_relationships_on_delivery_partner_id  (delivery_partner_id)
#  index_provider_relationships_on_discarded_at         (discarded_at)
#  index_provider_relationships_on_lead_provider_id     (lead_provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (delivery_partner_id => delivery_partners.id)
#  fk_rails_...  (lead_provider_id => lead_providers.id)
#
class ProviderRelationship < DiscardableRecord
  belongs_to :cohort
  belongs_to :lead_provider
  belongs_to :delivery_partner
end
