# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let(:school) { create(:school, urn: "123456", name: "My first High School") }
  let(:cohort) { create(:cohort, :current) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }
  let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort:) }

  context "with API V3 feature flag enabled", with_feature_flags: { api_v3: "active" } do
    path "/api/v3/partnerships/ecf" do
      get "<b>Note, this endpoint is new.</b><br/>Retrieve multiple ECF partnerships" do
        operationId :partnerships_ecf_get
        tags "ECF partnerships"
        security [bearerAuth: []]

        let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }

        parameter name: :filter,
                  schema: {
                    "$ref": "#/components/schemas/PartnershipsFilter",
                  },
                  in: :query,
                  style: :deepObject,
                  explode: true,
                  required: false,
                  description: "Refine partnerships to return.",
                  example: "filter[cohort]=2021,2022"

        parameter name: :sort,
                  in: :query,
                  schema: {
                    "$ref": "#/components/schemas/PartnershipsSort",
                  },
                  style: :form,
                  explode: false,
                  required: false,
                  description: "Sort partnerships being returned.",
                  example: "sort=-updated_at"

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

    path "/api/v3/partnerships/ecf/{id}" do
      get "<b>Note, this endpoint is new.</b><br/>Get a single ECF partnership" do
        operationId :partnerships_ecf_get
        tags "ECF partnerships"
        security [bearerAuth: []]

        let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }

        parameter name: :id,
                  in: :path,
                  required: true,
                  example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                  description: "The ID of the ECF participant.",
                  schema: {
                    type: "string",
                  }

        response "200", "A single partnership" do
          let(:id) { partnership.id }

          schema({ "$ref": "#/components/schemas/ECFPartnershipResponse" })

          run_test!
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid" }
          let(:id) { partnership.id }

          schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

          run_test!
        end

        response "404", "Not Found", exceptions_app: true do
          let(:id) { "test" }

          schema({ "$ref": "#/components/schemas/NotFoundResponse" })

          run_test!
        end
      end
    end

    path "/api/v3/partnerships/ecf" do
      post "<b>Note, this endpoint is new.</b><br/>Create an ECF partnership with a school and delivery partner" do
        operationId :partnerships_ecf_post
        tags "ECF partnerships"
        security [bearerAuth: []]
        consumes "application/json"

        let(:params) do
          {
            "data": {
              "type": "ecf-partnership",
              "attributes": {
                "cohort": cohort.start_year,
                "school_id": school.id,
                "delivery_partner_id": delivery_partner.id,
              },
            },
          }
        end

        parameter name: :params,
                  in: :body,
                  style: :deepObject,
                  required: true,
                  schema: {
                    "$ref": "#/components/schemas/ECFPartnershipRequest",
                  }

        response "200", "Create an ECF partnership" do
          schema({ "$ref": "#/components/schemas/ECFPartnershipResponse" })

          after do |example|
            content = example.metadata[:response][:content] || {}

            example_spec = {
              "application/json" => {
                examples: {
                  success: {
                    value: JSON.parse({
                      data: {
                        id: "cd3a12347-7308-4879-942a-c4a70ced400a",
                        type: "partnership",
                        attributes: {
                          cohort: 2021,
                          urn: "123456",
                          school_id: "dd4a11347-7308-4879-942a-c4a70ced400v",
                          delivery_partner_id: "db2fbf67-b7b7-454f-a1b7-0020411e2314",
                          delivery_partner_name: "Delivery Partner Example",
                          status: "active",
                          challenged_reason: nil,
                          challenged_at: nil,
                          induction_tutor_name: "John Doe",
                          induction_tutor_email: "john.doe@example.com",
                          updated_at: "2021-05-31T02:22:32.000Z",
                          created_at: "2021-05-31T02:22:32.000Z",
                        },
                      },
                    }.to_json, symbolize_names: true),
                  },
                },
              },
            }

            example.metadata[:response][:content] = content.deep_merge(example_spec)
          end

          run_test!
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid" }

          schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

          run_test!
        end

        response "422", "Unprocessable entity" do
          let(:params) do
            {
              "data": {
                "type": "ecf-partnership",
                "attributes": {
                  "cohort": nil,
                  "school_id": nil,
                  "delivery_partner_id": nil,
                },
              },
            }
          end
          schema({ "$ref": "#/components/schemas/ECFPartnershipRequestErrorResponse" })

          run_test!
        end
      end
    end
  end

  context "with API V3 feature flag disabled", api_v3: true do
    path "/api/v3/partnerships/ecf/{id}" do
      put "<b>Note, this endpoint is new.</b><br/>Update a partnership’s delivery partner in an existing partnership in a cohort" do
        operationId :partnerships_ecf_put
        tags "ECF partnerships"
        security [bearerAuth: []]
        consumes "application/json"

        parameter name: :id,
                  in: :path,
                  required: true,
                  example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                  description: "The ID of the partnership to update",
                  schema: {
                    type: "string",
                  }

        parameter name: :params,
                  in: :body,
                  style: :deepObject,
                  required: true,
                  schema: {
                    "$ref": "#/components/schemas/ECFPartnershipUpdateRequest",
                  }

        response "200", "Update an ECF partnership" do
          schema({ "$ref": "#/components/schemas/ECFPartnershipResponse" })

          # TODO: replace with actual implementation once implemented
          after do |example|
            content = example.metadata[:response][:content] || {}

            example_spec = {
              "application/json" => {
                examples: {
                  success: {
                    value: JSON.parse({
                      data: {
                        id: "cd3a12347-7308-4879-942a-c4a70ced400a",
                        type: "partnership",
                        attributes: {
                          cohort: 2021,
                          urn: "123456",
                          school_id: "dd4a11347-7308-4879-942a-c4a70ced400v",
                          delivery_partner_id: "db2fbf67-b7b7-454f-a1b7-0020411e2314",
                          delivery_partner_name: "Delivery Partner Example",
                          status: "active",
                          challenged_reason: nil,
                          challenged_at: nil,
                          induction_tutor_name: "John Doe",
                          induction_tutor_email: "john.doe@example.com",
                          updated_at: "2021-05-31T02:22:32.000Z",
                          created_at: "2021-05-31T02:22:32.000Z",
                        },
                      },
                    }.to_json, symbolize_names: true),
                  },
                },
              },
            }

            example.metadata[:response][:content] = content.deep_merge(example_spec)
          end

          run_test!
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid" }

          schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

          run_test!
        end

        response "422", "Unprocessable entity" do
          schema({ "$ref": "#/components/schemas/ECFPartnershipRequestErrorResponse" })

          run_test!
        end
      end
    end
  end
end
