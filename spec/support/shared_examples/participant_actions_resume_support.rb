# frozen_string_literal: true

RSpec.shared_examples "JSON Participant Resume endpoint" do |serialiser_type|
  let(:parsed_response) { JSON.parse(response.body) }

  it "changes the training status of a participant to active" do
    put(url, params:)

    expect(response).to be_successful

    expect(parsed_response.dig("data", "type")).to eq(serialiser_type)
  end

  it "returns an error when the participant is already active" do
    2.times { put url, params: }

    expect(response).not_to be_successful
  end

  it "returns an error when the participant is already withdrawn" do
    put withdrawal_url, params: withdrawal_params
    put(url, params:)

    expect(response).not_to be_successful
  end
end

RSpec.shared_examples "JSON Participant resume documentation" do |url, request_schema_ref, response_schema_ref, tag|
  humanised_description = TAG_TO_HUMANISED_DESCRIPTION[tag]
  operation_id = TAG_TO_OPERATION_ID[tag]

  path url do
    put "Notify that an #{humanised_description} is resuming their course" do
      operationId operation_id
      tags tag
      security [bearerAuth: []]
      consumes "application/json"

      request_body_example value: {
        "schema": {
          "$ref": request_schema_ref,
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

      response "200", "The #{humanised_description} being resumed" do
        let(:id) { participant.participant_identity.external_identifier }

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
