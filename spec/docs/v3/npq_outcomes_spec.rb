# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/outcomes/npq/{id}" do
    get "Retrieve NPQ outcomes for the specified participant" do
      operationId :npq_outcome_get
      tags "outcomes"
      security [bearerAuth: []]

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
end
