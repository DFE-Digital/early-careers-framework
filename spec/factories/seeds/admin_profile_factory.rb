# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_admin_profile, class: "AdminProfile") do
    trait(:with_user) { association(:user, factory: :seed_user) }
    trait(:valid) { with_user }

    after(:build) do |ap|
      if ap.user.present?
        Rails.logger.debug("built admin profile for #{ap.user.full_name} (#{ap.user.id})")
      else
        Rails.logger.debug("built admin profile with no user")
      end
    end
  end
end
