# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/participants/npq/{id}/outcomes" do
    get "Retrieve NPQ outcomes for the specified participant" do
      operationId :npq_outcome_get
      tags "outcomes"
      security [bearerAuth: []]

      parameter name: :id,
                description: "The unique ID of the participant",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "70885c85-f52b-45fe-b969-e09a93ffc6ee"

      response "200", "Successfully return NPQ outcomes" do
        schema({ "$ref": "#/components/schemas/NPQOutcomesResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/npq/{id}/outcomes" do
    post "Submit an NPQ outcome" do
      operationId :npq_outcome_post
      tags "outcomes"
      security [bearerAuth: []]

      parameter name: :id,
                description: "The unique ID of the participant",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "70885c85-f52b-45fe-b969-e09a93ffc6ee"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/NPQOutcomeRequest",
          },
        },
      }

      response "200", "Successfully submit an NPQ outcome" do
        schema({ "$ref": "#/components/schemas/NPQOutcomeResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end
end
