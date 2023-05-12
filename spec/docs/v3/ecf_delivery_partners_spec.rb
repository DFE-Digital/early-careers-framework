# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json", with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  let(:cohort) { create(:cohort, :current) }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }

  path "/api/v3/delivery-partners" do
    get "<b>Note, this endpoint is new.</b><br/>Retrieve delivery partners" do
      operationId :delivery_patrners_get
      tags "delivery partners"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/DeliveryPartnersFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine delivery partners to return.",
                example: CGI.unescape({
                  filter: {
                    cohort: "2021",
                  },
                }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of delivery partners."

      parameter name: :sort,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/DeliveryPartnersSort",
                },
                style: :form,
                explode: false,
                required: false,
                description: "Sort delivery partners being returned.",
                example: "sort=-updated_at"

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
    get "<b>Note, this endpoint is new.</b><br/>Retrieve a specific delivery partner" do
      operationId :delivery_patrner_get
      tags "delivery partners"
      security [bearerAuth: []]

      parameter name: :id,
                description: "The unique ID of the delivery partner",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "00acafd3-e6f6-41e7-a770-3207be94f755"

      response "200", "Successfully return a specific delivery partner" do
        let(:id) { delivery_partner.id }
        schema({ "$ref": "#/components/schemas/DeliveryPartnerResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { delivery_partner.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "404", "Not Found", exceptions_app: true do
        let(:id) { "unknown-id" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end
    end
  end
end
