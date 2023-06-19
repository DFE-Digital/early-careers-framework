# frozen_string_literal: true

FactoryBot.define do
  factory :participant_outcome_api_request do
    association :participant_outcome

    trait :with_trn_success do
      request_path { "https://example.com/v2/npq-qualifications?trn=1234567" }
      status_code { 204 }
      request_headers do
        {
          "host"=>"example.com",
          "accept"=>"*/*",
          "user-agent"=>"Ruby",
          "content-type"=>"application/json",
          "content-length"=>"59",
          "accept-encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        }
      end
      request_body { { "completionDate" => "2023-02-21", "qualificationType" => "NPQLT" } }
      response_body { nil }
      response_headers do
        {
          "date"=>"Thu, 11 May 2023 12:44:39 GMT",
          "connection"=>"keep-alive",
          "request-context"=>"appId=cid-v1:b3114e2d-c1ab-4870-90b8-88ccc4bdc491",
          "x-frame-options"=>"deny",
          "x-xss-protection"=>"0",
          "x-vcap-request-id"=>"6aaeb6a1-1697-4e12-694e-a9c3d4c63250",
          "x-rate-limit-limit"=>"60s",
          "x-rate-limit-reset"=>"2023-05-11T12:45:00.0000000Z",
          "x-content-type-options"=>"nosniff",
          "x-rate-limit-remaining"=>"225",
          "strict-transport-security"=>"max-age=31536000; includeSubDomains; preload",
        }
      end
    end

    trait :with_trn_not_found do
      status_code { 404 }
      response_body { { errorCode: 10_001 } }
    end
  end
end
