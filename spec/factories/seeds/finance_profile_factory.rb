# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_finance_profile, class: "FinanceProfile") do
    trait(:with_user) { association(:user, factory: :seed_user) }

    trait(:valid) { with_user }

    after(:build) do |fp|
      if fp.user.present?
        Rails.logger.debug("seeded finance profile for user #{fp.user.full_name}")
      else
        Rails.logger.debug("seeded incomplete finance profile")
      end
    end
  end
end
