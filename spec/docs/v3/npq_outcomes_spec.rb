# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/outcomes/npq" do
    get "Retrieve NPQ outcomes for the specified participant" do
      operationId :npq_outcome_get
      tags "outcomes"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/NPQOutcomesFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: true,
                description: "Refine NPQ outcomes to return.",
                example: CGI.unescape({
                  filter: {
                    participant_id: "dcb52af5-e2c9-4f30-8138-60e7dfb54e36",
                  },
                }.to_param)

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

  path "/api/v3/outcomes/npq" do
    post "Submit an NPQ outcome" do
      operationId :npq_outcome_post
      tags "outcomes"
      security [bearerAuth: []]

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
