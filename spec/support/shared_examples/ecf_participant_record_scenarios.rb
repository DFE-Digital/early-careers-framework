# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "The support for ECTs service cannot see the participants details" do
  let(:app_service_token) { EngageAndLearnApiToken.create_with_random_token! }

  let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
  let(:api_record_ids) { parsed_response[:data].map { |record| record[:id] } }
  let(:api_record) { parsed_response[:data][0] }

  it "cannot see a record with the correct Id listed" do
    default_headers[:Authorization] = "Bearer #{app_service_token}"

    get "/api/v1/ecf-users"

    expect(api_record_ids).to_not include participant_profile.user.id
  end
end

RSpec.shared_examples "As their current delivery provider" do
  let(:delivery_partner_user) do
    NewSeeds::Scenarios::Users::DeliveryPartnerUser
      .new(delivery_partner:)
      .build
      .user
  end

  it "can see the participant listed in the delivery partner participants dashboard" do
    sign_in_as delivery_partner_user

    get "/delivery-partners/#{delivery_partner.id}/participants"

    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
    expect(response.body).to include(CGI.escapeHTML(preferred_identity.email))
  end
end
