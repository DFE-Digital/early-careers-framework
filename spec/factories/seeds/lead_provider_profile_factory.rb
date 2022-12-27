# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_lead_provider_profile, class: "LeadProviderProfile") do
    trait(:with_user) { association(:user, factory: :seed_user) }
    trait(:with_lead_provider) { association(:lead_provider, factory: :seed_lead_provider) }

    trait(:valid) do
      with_user
      with_lead_provider
    end

    after(:build) do |lp|
      if lp.user.present? && lp.lead_provider.present?
        Rails.logger.debug("seeded lead provider profile for user #{lp.user.full_name} at #{lp.lead_provider.name}")
      else
        Rails.logger.debug("seeded incomplete lead provider profile")
      end
    end
  end
end
