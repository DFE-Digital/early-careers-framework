# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:mentor_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
  let!(:induction_record) { create(:induction_record, induction_programme:, mentor_profile:) }
  let!(:unfunded_mentor_profile) { create(:mentor, :eligible_for_funding) }
  let!(:another_induction_record) { create(:induction_record, induction_programme:, mentor_profile: unfunded_mentor_profile) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v3/unfunded-mentors/ecf" do
    get "<b>Note, this endpoint is new.</b><br/>Retrieve multiple unfunded mentors" do
      operationId :participants
      tags "unfunded mentors"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine unfunded mentors to return.",
                example: CGI.unescape({ filter: { updated_since: "2020-11-13T11:21:55Z" } }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of unfunded mentors."

      parameter name: :sort,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ECFUnfundedMentorsSort",
                },
                style: :form,
                explode: false,
                required: false,
                description: "Sort unfunded mentors being returned.",
                example: "sort=-updated_at"

      response "200", "A list of unfunded mentors" do
        schema({ "$ref": "#/components/schemas/MultipleUnfundedMentorsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/unfunded-mentors/ecf/{id}" do
    get "<b>Note, this endpoint is new.</b><br/>Get a single unfunded mentor" do
      operationId :unfunded_mentors
      tags "unfunded mentors"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the unfunded mentor.",
                schema: {
                  type: :string,
                  format: :uuid,
                }

      response "200", "A single unfunded mentor" do
        let(:id) { unfunded_mentor_profile.user.id }

        schema({ "$ref": "#/components/schemas/UnfundedMentorResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { unfunded_mentor_profile.user.id }
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
