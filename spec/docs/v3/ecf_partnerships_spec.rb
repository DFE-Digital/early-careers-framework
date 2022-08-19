# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  path "/api/v3/partnerships/ecf" do
    get "Retrieve multiple ECF partnerships" do
      operationId :partnerships_ecf_get
      tags "ECF partnerships"
      security [bearerAuth: []]

      parameter name: :filter,
                schema: {
                  "$ref": "#/components/schemas/PartnershipsFilter",
                },
                in: :query,
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine partnerships to return.",
                example: "filter[cohort]=2021,2022"

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

        # TODO: replace with actual implementation once implemented
        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                create_partnership: {
                  value: {
                    data: {
                      id: "cd3a12347-7308-4879-942a-c4a70ced400a",
                      type: "partnership",
                      attributes: {
                        cohort: 2021,
                        urn: "123456",
                        delivery_partner_id: "cd3a12347-7308-4879-942a-c4a70ced400a",
                        status: "active",
                        challenged_reason: nil,
                        induction_tutor_name: "John Doe",
                        induction_tutor_email: "john.doe@example.com",
                        updated_at: "2021-05-31T02:22:32.000Z",
                        created_at: "2021-05-31T02:22:32.000Z",
                      },
                    },
                  },
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
