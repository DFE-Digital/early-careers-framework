# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe "participant-declarations endpoint spec", type: :request do
  include_context "lead provider profiles and courses"

  describe "post" do
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }
    let(:payload) { create(:participant_profile, :ect) }
    let(:valid_params) do
      {
        participant_id: payload.user.id,
        declaration_type: "started",
        declaration_date: (Time.zone.now - 1.week).iso8601,
        course_identifier: "ecf-induction",
      }
    end

    let(:invalid_user_id) do
      valid_params.merge({ participant_id: payload.id })
    end
    let(:incorrect_course_identifier) do
      valid_params.merge({ course_identifier: "typoed-course-name" })
    end
    let(:invalid_course_identifier) do
      valid_params.merge({ course_identifier: "ecf-mentor" })
    end
    let(:missing_user_id) do
      valid_params.merge({ participant_id: "" })
    end
    let(:missing_attribute) do
      valid_params.except(:participant_id)
    end

    let(:parsed_response) { JSON.parse(response.body) }

    def build_params(attributes)
      {
        data: {
          type: "participant-declaration",
          attributes: attributes,
        },
      }.to_json
    end

    context "when authorized" do
      let(:parsed_response) { JSON.parse(response.body) }

      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      it "create declaration record and declaration attempt and return id when successful" do
        expect { post "/api/v1/participant-declarations", params: build_params(valid_params) }
            .to change(ParticipantDeclaration, :count).by(1)
            .and change(ParticipantDeclarationAttempt, :count).by(1)
        expect(response.status).to eq 200
        expect(parsed_response["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      context "when lead provider has no access to the user" do
        before do
          partnership.update!(lead_provider: create(:lead_provider))
        end

        it "create declaration attempt" do
          expect { post "/api/v1/participant-declarations", params: build_params(valid_params) }
              .to change(ParticipantDeclarationAttempt, :count).by(1)
        end

        it "does not create declaration" do
          expect { post "/api/v1/participant-declarations", params: build_params(valid_params) }
              .not_to change(ParticipantDeclaration, :count)
          expect(response.status).to eq 422
        end
      end

      it "returns 422 when trying to create for an invalid user id" do # Expects the user uuid. Pass the early_career_teacher_profile_id
        post "/api/v1/participant-declarations", params: build_params(invalid_user_id)
        expect(response.status).to eq 422
      end

      it "returns 422 when trying to create with no id" do
        post "/api/v1/participant-declarations", params: build_params(missing_user_id)
        expect(response.status).to eq 422
      end

      it "returns 422 when a required parameter is missing" do
        post "/api/v1/participant-declarations", params: build_params(missing_attribute)
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: %w[participant_id] }.to_json)
      end

      it "returns 422 when supplied an incorrect course type" do
        post "/api/v1/participant-declarations", params: build_params(incorrect_course_identifier)
        expect(response.status).to eq 422
      end

      it "returns 422 when a participant type doesn't match the course type" do
        post "/api/v1/participant-declarations", params: build_params(invalid_course_identifier)
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: ["The property '#/course_identifier' must be an available course to '#/participant_id'"] }.to_json)
      end

      it "returns 422 when there are multiple errors" do
        post "/api/v1/participant-declarations", params: build_params("")
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: %w[participant_id declaration_date declaration_type course_identifier] }.to_json)
      end

      it "returns 400 when the data block is incorrect" do
        post "/api/v1/participant-declarations", params: {}.to_json
        expect(response.status).to eq 400
        expect(response.body).to eq({ bad_request: I18n.t(:invalid_data_structure) }.to_json)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v1/participant-declarations", params: build_params(valid_params)
        expect(response.status).to eq 401
      end
    end
  end
end
