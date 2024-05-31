# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v2/api_spec.json" do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { npq_lead_provider.cpd_lead_provider }
  let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
  let(:funding_cap) { 10 }
  let!(:statement) do
    create(
      :npq_statement,
      :next_output_fee,
      cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
      cohort: npq_application.cohort,
    )
  end
  let!(:npq_contract) do
    create(
      :npq_contract,
      npq_lead_provider:,
      cohort: statement.cohort,
      course_identifier: npq_course.identifier,
      version: statement.contract_version,
      funding_cap:,
    )
  end

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }

  let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:, npq_course:, eligible_for_funding: true) }

  before do
    FeatureFlag.activate(:npq_capping)
  end

  path "/api/v2/npq-applications/{id}/change-funded-place" do
    put "Change funded place" do
      operationId :npq_applications_change_funded_place
      tags "NPQ applications"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ application to change funded place.",
                schema: {
                  type: :string,
                  format: :uuid,
                }

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: false,
                schema: {
                  "$ref": "#/components/schemas/ChangeFundedPlaceRequest",
                }

      response "200", "The NPQ application being accepted" do
        let(:id) { npq_application.id }

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": {
                funded_place: true,
              },
            },
          }
        end

        schema({ "$ref": "#/components/schemas/NPQApplicationResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

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
end
