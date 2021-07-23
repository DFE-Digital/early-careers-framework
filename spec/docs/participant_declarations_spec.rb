# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Participant Declarations", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:early_career_teacher_profile) { create(:early_career_teacher_profile) }
  let(:cohort) { early_career_teacher_profile.cohort }
  let(:user) { early_career_teacher_profile.user }
  let(:lead_provider) { create(:lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participant-declarations" do
    post "Declare a participant has reached a milestone" do
      operationId :participant_declarations
      tags "Participant declarations"
      consumes "application/json"
      security [bearerAuth: []]

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ParticipantDeclaration",
          },
        },
      }

      parameter name: :params,
                in: :body,
                schema: {
                  "$ref": "#/components/schemas/ParticipantDeclaration",
                }

      response 200, "Successful" do
        let(:fresh_user) { create(:user, :early_career_teacher) }
        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": {
                "participant_id" => fresh_user.id,
                "declaration_type" => "started",
                "declaration_date" => "2021-05-31T15:50:00Z",
                "course_identifier" => "ecf-induction",
              },
            },
          }
        end
        run_test!
      end

      response 200, "Successful" do
        let(:attributes) do
          {
            "participant_id" => user.id,
            "declaration_type" => "started",
            "declaration_date" => "2021-05-31T15:50:00Z",
            "course_identifier" => "ecf-induction",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": attributes,
            },
          }
        end

        before do
          caller_attributes = attributes.merge({ cpd_lead_provider: cpd_lead_provider, raw_event: params.to_json })
          RecordParticipantDeclaration.call(HashWithIndifferentAccess.new(caller_attributes))
        end

        schema "$ref": "#/components/schemas/ParticipantDeclarationRecordedResponse"

        run_test!
      end

      response "422", "Bad or Missing parameter" do
        let(:user) { build(:user, :early_career_teacher) }

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": {
              },
            },
          }
        end

        schema "$ref": "#/components/schemas/BadOrMissingParametersResponse"

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema "$ref": "#/components/schemas/UnauthorisedResponse"

        run_test!
      end

      response "400", "Bad Request" do
        schema "$ref": "#/components/schemas/BadRequestResponse"

        run_test!
      end
    end
  end
end
