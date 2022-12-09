# frozen_string_literal: true

FactoryBot.define do
  factory :seed_appropriate_body_profile, class: "AppropriateBodyProfile" do
    trait(:with_appropriate_body) { association(:appropriate_body, factory: :seed_appropriate_body) }
    trait(:with_user) { association(:user, factory: :seed_user) }

    trait(:valid) do
      with_appropriate_body
      with_user
    end

    after(:build) do |ab|
      if ab.appropriate_body.present? && ab.user.present?
        Rails.logger.debug("seeded appropriate body #{ab.user.full_name} works for #{ab.appropriate_body.name}")
      else
        Rails.logger.debug("seeded incomplete appropriate body")
      end
    end
  end
end
