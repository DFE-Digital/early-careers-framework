# frozen_string_literal: true

FactoryBot.define do
  factory :participant_outcome, class: "ParticipantOutcome::NPQ" do
    association :participant_declaration, factory: :npq_participant_declaration

    completion_date { Date.yesterday }
    state { :passed }

    trait :passed do
      state { :passed }
    end

    trait :failed do
      state { :failed }
    end

    trait :voided do
      state { :voided }
    end

    trait :sent_to_qualified_teachers_api do
      sent_to_qualified_teachers_api_at { Time.zone.now - 1.hour }
    end

    trait :not_sent_to_qualified_teachers_api do
      sent_to_qualified_teachers_api_at { nil }
    end
  end
end
