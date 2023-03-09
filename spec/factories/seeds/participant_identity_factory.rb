# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_participant_identity, class: "ParticipantIdentity") do
    external_identifier { SecureRandom.uuid }

    # it's confusing when working with seeded data and the email adddress in
    # the participant identity doesn't resemble the name in the user, so by
    # default let's use a generic one by default but allow override if
    # necessary
    email { "participant-identity-#{SecureRandom.hex(4)}@example.com" }

    trait :with_user do
      association(:user, factory: :seed_user)
      email { user.email }
      external_identifier { user.id }
    end

    trait :with_realistic_email_address do
      email { Faker::Internet.unique.email }
    end

    trait(:valid) { with_user }

    after(:build) do |pi|
      if pi.user.present?
        Rails.logger.debug("seeded participant_identity for user #{pi.user.full_name}")
      else
        Rails.logger.debug("seeded participant_identity with no user")
      end
    end
  end
end
