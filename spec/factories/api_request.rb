# frozen_string_literal: true

FactoryBot.define do
  factory :api_request do
    association :cpd_lead_provider

    request_path { "/api/v3/npq-applications" }
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
    request_body { { "page" => { "page" => "61", "per_page" => "100" }, "filter" => { "updated_since"=>"1970-01-01T00:00:00+01:00" } } }
    response_body { nil }
    request_method { "GET" }
    response_headers { { "Content-Type"=>"application/vnd.api+json" } }
    user_description { "CPD lead provider: Test" }

    trait :unprocessable_entity do
      status_code { 422 }
    end

    trait :success do
      status_code { 200 }
    end

    trait :errors do
      status_code { 400 }
      response_body do
        { "errors"=>
      [{ "title"=>"test_id",
        "detail"=>
         "Test error message" }] }
      end
    end
  end
end
