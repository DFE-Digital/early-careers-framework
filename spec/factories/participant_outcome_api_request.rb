# frozen_string_literal: true

FactoryBot.define do
  factory :participant_outcome_api_request do
    association :participant_outcome

    trait :with_trn_not_found do
      status_code { 404 }
      response_body { { errorCode: 10_001 } }
    end
  end
end
