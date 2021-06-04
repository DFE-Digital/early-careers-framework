# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Participant Declarations", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:early_career_teacher_profile) { create(:early_career_teacher_profile) }
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
      security [bearerAuth: []]
      request_body content: {
        "application/json": {
          "schema": {
            "type": "object",
            "properties": {
              "participant_id": {
                "type": "string",
              },
              "declaration_type": {
                "enum": ["Start"]
              },
              "declaration_date": {
                "type": "string",
                "format": "date"
              }
            },
            "required": ["participant_id", "declaration_type", "declaration_date"],
            "example": {
              "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
              "declaration_type": "Start",
              "declaration_date": "2021-05-31"
            },
          },
        },
      }
      parameter name: :params, in: :body, required: true, schema: {
        type: :object,
        properties: {
          participant_id: { type: :string },
        },
      }, description: "The unique id of the participant"

      parameter name: :params, in: :body, required: false, schema: {
        type: :object,
        properties: {
          declaration_type: { enum: ["Start"] },
        },
      }, description: "The event declaration type"

      parameter name: :params, in: :body, required: false, schema: {
        type: :object,
        properties: {
          declaration_date: { type: :string, format: "date" },
        },
      }, description: "The event declaration date"

      response 204, "Successful" do
        let(:fresh_user) { create(:user, :early_career_teacher) }
        let(:params) {
          {
            "lead_provider" => lead_provider,
            "participant_id" => fresh_user.id,
            "declaration_type" => "Start",
            "declaration_date" => "2021-05-31"
          } }
        run_test!
      end

      # response 304, "Not Modified" do
      #   let(:params) {
      #     {
      #       "participant_id" => user.id,
      #       "declaration_type" => "Start",
      #       "declaration_date" => "2021-05-31"
      #     } }
      #
      #   before do
      #     RecordParticipantEvent.call(params.merge({lead_provider: lead_provider}))
      #   end
      #
      #   run_test!
      # end

      response 204, "Duplicate successful" do
        let(:params) {
          {
            "participant_id" => user.id,
            "declaration_type" => "Start",
            "declaration_date" => "2021-05-31"
          } }

        before do
          RecordParticipantEvent.call(HashWithIndifferentAccess.new({lead_provider: lead_provider}).merge(params))
        end

        run_test!
      end

      response "404", "Missing ID value" do
        let(:params) {
          {
            "participant_id" => nil,
            "declaration_type" => "",
            "declaration_date" => ""
          } }
        run_test!
      end

      response "404", "Not Found" do
        let(:fresh_user) { build(:user, :early_career_teacher) }
        let(:params) {
          {
            "participant_id" => fresh_user.id,
            "declaration_type" => "",
            "declaration_date" => ""
          } }
        run_test!
      end

      response "422", "Missing parameter" do
        let(:fresh_user) { build(:user, :early_career_teacher) }
        let(:params) {
          {
            "declaration_type" => "Start",
            "declaration_date" => "2021-05-21"
          } }
        run_test!
      end

      response "422", "Missing parameter" do
        let(:fresh_user) { create(:user, :early_career_teacher) }
        let(:params) {
          {
            "participant_id" => fresh_user.id,
            "declaration_date" => "2021-05-21"
          } }
        run_test!
      end

      response "422", "Missing parameter" do
        let(:fresh_user) { create(:user, :early_career_teacher) }
        let(:params) {
          {
            "participant_id" => fresh_user.id,
            "declaration_type" => "Start",
          } }
        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end
end
