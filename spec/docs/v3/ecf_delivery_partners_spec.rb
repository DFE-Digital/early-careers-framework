# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/delivery-partners" do
    get "Retrieve delivery partners" do
      operationId :delivery_patrners_get
      tags "delivery partners"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/DeliveryPartnersFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine delivery partners to return.",
                example: CGI.unescape({
                  filter: {
                    cohort: "2021",
                  },
                }.to_param)

      response "200", "Successfully return a list of delivery partners" do
        schema({ "$ref": "#/components/schemas/DeliveryPartnersResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/delivery-partners/{id}" do
    get "Retrieve a specific delivery partner" do
      operationId :delivery_patrner_get
      tags "delivery partners"
      security [bearerAuth: []]

      response "200", "Successfully return a specific delivery partner" do
        schema({ "$ref": "#/components/schemas/DeliveryPartnerResponse" })

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
