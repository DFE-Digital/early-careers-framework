# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_coordinator_profile, class: "InductionCoordinatorProfile") do
    trait(:with_user) { association(:user, factory: :seed_user) }
    trait(:valid) { with_user }

    after(:build) do |icp|
      if icp.user.present?
        Rails.logger.debug("seeded induction coordination profile for user #{icp.user.full_name}")
      else
        Rails.logger.debug("seeded incomplete induction coordinator profile")
      end
    end
  end
end
