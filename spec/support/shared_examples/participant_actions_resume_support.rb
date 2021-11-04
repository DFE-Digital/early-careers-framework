# frozen_string_literal: true

RSpec.shared_examples "a participant resume action service" do
  it_behaves_like "a participant action service"

  it "creates an active state and makes the profile active" do
    expect { described_class.call(params: given_params) }.to change { ParticipantProfileState.count }.by(1)
    expect(user_profile.participant_profile_state).to be_active
    expect(user_profile).to be_training_status_active
  end

  it "fails when the participant is already active" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "active")
    expect { described_class.call(params: given_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "fails when the participant is already withdrawn" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn")
    expect { described_class.call(params: given_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

RSpec.shared_examples "JSON Participant Resume endpoint" do |serialiser_type|
  let(:parsed_response) { JSON.parse(response.body) }

  it "changes the training status of a participant to active" do
    put url, params: params

    expect(response).to be_successful

    expect(parsed_response.dig("data", "type")).to eq(serialiser_type)
  end

  it "returns an error when the participant is already active" do
    2.times { put url, params: params }

    expect(response).not_to be_successful
  end

  it "returns an error when the participant is withdrawn" do
    put withdrawal_url, params: withdrawal_params
    put url, params: params

    expect(response).not_to be_successful
  end
end

RSpec.shared_examples "JSON Participant resume documentation" do |url, request_schema_ref, response_schema_ref, tag|
  path url do
    put "Notify that a participant is resuming their course" do
      operationId :participant
      tags tag
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": request_schema_ref,
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to resume"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": request_schema_ref,
                }

      response "200", "The participant being resumed" do
        let(:id) { participant.user_id }

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": response_schema_ref })
        run_test!
      end
    end
  end
end
