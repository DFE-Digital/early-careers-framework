# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_provider_profiles
#
#  id               :uuid             not null, primary key
#  discarded_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lead_provider_id :uuid             not null
#  user_id          :uuid             not null
#
# Indexes
#
#  index_lead_provider_profiles_on_discarded_at      (discarded_at)
#  index_lead_provider_profiles_on_lead_provider_id  (lead_provider_id)
#  index_lead_provider_profiles_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (lead_provider_id => lead_providers.id)
#  fk_rails_...  (user_id => users.id)
#
class LeadProviderProfile < BaseProfile
  belongs_to :user
  belongs_to :lead_provider
end
