# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/statements" do
    get "Retrieve financial statements" do
      operationId :statements_get
      tags "statements"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/StatementsFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine statements to return.",
                example: CGI.unescape({
                  filter: {
                    cohort: "2021,2022",
                    type: "ecf",
                  },
                }.to_param)

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

  path "/api/v3/statements/{id}" do
    get "Retrieve specific financial statement" do
      operationId :statement_get
      tags "statements"
      security [bearerAuth: []]

      response "200", "A specific financial statement" do
        schema({ "$ref": "#/components/schemas/StatementResponse" })

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
