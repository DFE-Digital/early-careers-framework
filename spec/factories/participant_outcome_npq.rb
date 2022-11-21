# frozen_string_literal: true

FactoryBot.define do
  factory :participant_outcome, class: "ParticipantOutcome::NPQ" do
    association :participant_declaration

    completion_date { Date.yesterday }
    state { :passed }

    trait :failed do
      state { :failed }
    end
  end
end
