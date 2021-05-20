# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Early Career Teacher Participation", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:user) { create(:user) }
  let(:lead_provider) { create(:lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/early-career-teacher-participants" do
    post "Add Early Career Teacher to Course" do
      operationId :api_v1_create_ect_participant
      tags "ect_participant"
      consumes "application/json"
      security [bearerAuth: []]
      request_body content: {
        "application/json": {
          "schema": {
            "type": "object",
            "properties": {
              "name": "id",
              "type": "string",
            },
            "example": {
              "id": "db3a7848-7308-4879-942a-c4a70ced400a",
            },
          },
        },
      }
      parameter name: :params, in: :body, required: false, schema: {
        type: :object,
        properties: {
          id: { type: :string },
        },
      }, description: "The unique id of the participant"

      response 204, "Successful" do
        let(:fresh_user) { create(:user, :early_career_teacher) }
        let(:params) { { "id" => fresh_user.id } }
        run_test!
      end

      response 304, "Not Modified" do
        before do
          InductParticipant.call(user.early_career_teacher_profile)
        end
        let(:params) { { "id" => user.id } }
        run_test!
      end

      response "404", "Not Found" do
        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end
end
