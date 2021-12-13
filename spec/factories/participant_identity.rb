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

    # after(:create) do |participant_identity|
    #   ParticipantIdentity.find_or_create_by!(email: participant_identity.email) do |identity|
    #     identity.user = user
    #     identity.external_identifier = user.id
    #   end
    # end
  end
end
