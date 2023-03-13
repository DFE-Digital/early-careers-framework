# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json", with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }
  let(:cohort_2021) { create(:cohort, :current) }
  let(:cohort_2022) { create(:cohort, :next) }
  let!(:ecf_statement_cohort_2022) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: cohort_2022,
    )
  end
  let!(:ecf_statement_cohort_2021) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: cohort_2021,
    )
  end

  path "/api/v3/statements" do
    get "<b>Note, this endpoint is new.</b><br/>Retrieve financial statements" do
      operationId :statements_get
      tags "statements"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/StatementsFilter",
                },
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
    get "<b>Note, this endpoint is new.</b><br/>Retrieve specific financial statement" do
      operationId :statement_get
      tags "statements"
      security [bearerAuth: []]

      parameter name: :id,
                description: "The unique ID of the statement",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "fe82db5d-a7ff-42b4-9eb7-19a87bf0ce5f"

      response "200", "A specific financial statement" do
        let(:id) { ecf_statement_cohort_2022.id }

        schema({ "$ref": "#/components/schemas/StatementResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { ecf_statement_cohort_2022.id }

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
