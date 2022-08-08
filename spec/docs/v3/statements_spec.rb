# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/statements" do
    get "Retrieve financial statements" do
      operationId :statements_get
      tags "statements"
      security [bearerAuth: []]

      response "200", "A list of statements as part of which the DfE will make output payments for ecf or npq participants" do
        schema({ "$ref": "#/components/schemas/StatementsResponse" })

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
