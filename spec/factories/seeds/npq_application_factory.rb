# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_npq_application, class: "NPQApplication") do
    date_of_birth { 30.years.ago }

    trait(:with_participant_identity) do
      association(:participant_identity, factory: %i[seed_participant_identity valid])
    end

    trait(:with_npq_lead_provider) do
      association(:npq_lead_provider, factory: %i[seed_npq_lead_provider valid])
    end

    trait(:with_npq_course) do
      association(:npq_course, factory: %i[seed_npq_course])
    end

    trait(:valid) do
      with_participant_identity
      with_npq_lead_provider
      with_npq_course
    end

    after(:build) do
      Rails.logger.debug("Built an NPQ application")
    end
  end
end
