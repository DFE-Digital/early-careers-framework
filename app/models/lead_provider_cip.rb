# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_provider_cips
#
#  id                          :uuid             not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  cohort_id                   :uuid             not null
#  core_induction_programme_id :uuid             not null
#  lead_provider_id            :uuid             not null
#
# Indexes
#
#  index_lead_provider_cips_on_cohort_id                    (cohort_id)
#  index_lead_provider_cips_on_core_induction_programme_id  (core_induction_programme_id)
#  index_lead_provider_cips_on_lead_provider_id             (lead_provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (core_induction_programme_id => core_induction_programmes.id)
#  fk_rails_...  (lead_provider_id => lead_providers.id)
#
class LeadProviderCip < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :cohort
  belongs_to :core_induction_programme
end
