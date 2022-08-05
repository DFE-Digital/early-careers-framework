# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/partnerships/ecf" do
    get "Retrieve multiple ECF partnerships" do
      operationId :partnerships_ecf_get
      tags "ECF partnerships"
      security [bearerAuth: []]

      response "200", "A list of ECF partnerships" do
        schema({ "$ref": "#/components/schemas/MultipleECFPartnershipsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/partnerships/ecf" do
    post "Create an ECF partnership with a school and delivery partner" do
      operationId :partnerships_ecf_post
      tags "ECF partnerships"
      security [bearerAuth: []]

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ECFPartnershipRequest",
          },
        },
      }

      response "200", "Create an ECF partnership" do
        schema({ "$ref": "#/components/schemas/ECFPartnershipResponse" })

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
