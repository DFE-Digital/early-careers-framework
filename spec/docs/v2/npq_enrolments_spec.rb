# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v2/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }

  let!(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:) }

  path "/api/v2/npq-enrolments.csv" do
    get "Retrieve multiple NPQ enrolments" do
      operationId :npq_enrolments
      tags "NPQ enrolments"
      security [bearerAuth: []]
      produces "text/csv"

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ participants to return.",
                example: CGI.unescape({ updated_since: "2020-11-13T11:21:55Z" }.to_param)

      response "200", "A list of NPQ enrolments" do
        schema "$ref": "#/components/schemas/MultipleNPQEnrolmentsCsvResponse"

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
