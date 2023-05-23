# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json", with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }
  let(:cohort) { create(:cohort, start_year: 2021) }
  let!(:school) { create(:school, :eligible) }
  let("filter[cohort]") { cohort.start_year }

  path "/api/v3/schools/ecf" do
    get "<b>Note, this endpoint is new.</b><br/>Retrieve multiple ECF schools scoped to cohort" do
      operationId :school_ecf_get
      tags "ECF schools"
      security [bearerAuth: []]

      parameter name: "filter[cohort]",
                schema: {
                  "$ref": "#/components/schemas/ECFSchoolsFilter",
                },
                in: :query,
                style: :deepObject,
                explode: true,
                required: true,
                description: "Refine schools to return.",
                example: "filter[cohort]=2021"

      parameter name: "filter[urn]",
                schema: {
                  "$ref": "#/components/schemas/ECFSchoolsFilter",
                },
                in: :query,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine schools to return.",
                example: "filter[urn]=106286"

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of schools."

      parameter name: :sort,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ECFSchoolsSort",
                },
                style: :form,
                explode: false,
                required: false,
                description: "Sort schools being returned.",
                example: "sort=-updated_at"

      response "200", "A list of schools for the given cohort" do
        schema({ "$ref": "#/components/schemas/MultipleECFSchoolsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/schools/ecf/{id}" do
    let(:id) { school.id }

    get "<b>Note, this endpoint is new.</b><br/>Get a single ECF school scoped to cohort" do
      operationId :school_ecf_get
      tags "ECF schools"
      security [bearerAuth: []]

      parameter name: :id,
                description: "The unique ID of the school",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75"

      parameter name: "filter[cohort]",
                schema: {
                  "$ref": "#/components/schemas/ECFSchoolsFilter",
                },
                in: :query,
                style: :deepObject,
                explode: true,
                required: true,
                description: "Refine schools to return.",
                example: "filter[cohort]=2021"

      response "200", "A single school" do
        schema({ "$ref": "#/components/schemas/ECFSchoolResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

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
