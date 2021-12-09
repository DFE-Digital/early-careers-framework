# frozen_string_literal: true

FactoryBot.define do
  factory :participant_identity do
    user
    email { user.email }
    external_identifier { user.id }
    origin { "ecf" }

    trait :npq_origin do
      origin { "npq" }
    end

    initialize_with do
      ParticipantIdentity.find_or_create_by!(email: email) do |identity|
        identity.user = user
        identity.external_identifier = user.id
      end
    end
  end
end
