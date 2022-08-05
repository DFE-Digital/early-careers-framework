# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/delivery-partners/ecf" do
    get "Retrieve delivery partners for ECF" do
      operationId :delivery_patrners_ecf_get
      tags "ECF delivery partners"
      security [bearerAuth: []]

      response "200", "A list of ECF delivery partners" do
        schema({ "$ref": "#/components/schemas/ECFDeliveryPartnersResponse" })

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
