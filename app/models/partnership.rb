# frozen_string_literal: true

# == Schema Information
#
# Table name: partnerships
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cohort_id        :uuid             not null
#  lead_provider_id :uuid             not null
#  school_id        :uuid             not null
#
# Indexes
#
#  index_partnerships_on_cohort_id         (cohort_id)
#  index_partnerships_on_lead_provider_id  (lead_provider_id)
#  index_partnerships_on_school_id         (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (lead_provider_id => lead_providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Partnership < ApplicationRecord
  belongs_to :school
  belongs_to :lead_provider
  belongs_to :cohort
end
