# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Participant Declarations", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:early_career_teacher_profile) { create(:early_career_teacher_profile) }
  let(:cohort) { early_career_teacher_profile.cohort }
  let(:user) { early_career_teacher_profile.user }
  let(:lead_provider) { create(:lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participant-declarations" do
    post "Create participant declarations" do
      operationId :api_v1_create_ect_participant
      tags "participant_declarations"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      request_body required: true, content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ParticipantDeclaration",
          },
          "example": {
            "participant_id" => "db3a7848-7308-4879-942a-c4a70ced400a",
            "declaration_type" => "started",
            "declaration_date" => "2021-05-31T15:50:00Z",
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
            "participant_id" => fresh_user.id,
            "declaration_type" => "started",
            "declaration_date" => "2021-05-31T15:50:00Z",
          }
        end

        schema "$ref": "#/components/schemas/ParticipantDeclarationRecordedResponse"

        run_test!
      end

      response 200, "Successful" do
        let(:params) do
          {
            "participant_id" => user.id,
            "declaration_type" => "started",
            "declaration_date" => "2021-05-31T15:50:00Z",
          }
        end

        before do
          RecordParticipantEvent.call(HashWithIndifferentAccess.new({ lead_provider: lead_provider, raw_event: params.to_json }).merge(params))
        end

        schema "$ref": "#/components/schemas/ParticipantDeclarationRecordedResponse"

        run_test!
      end

      response "422", "Bad or Missing parameter" do
        let(:user) { build(:user, :early_career_teacher) }

        schema "$ref": "#/components/schemas/BadOrParameterMissingParameterResponse"

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema "$ref": "#/components/schemas/UnauthorizedResponse"

        run_test!
      end
    end
  end
end
