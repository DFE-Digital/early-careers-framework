# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe "participant-declarations endpoint spec", type: :request do
  include_context "lead provider profiles and courses"

  describe "post" do
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    let(:valid_params) do
      {
        participant_id: ect_profile.user.id,
        declaration_type: "started",
        declaration_date: (ect_profile.schedule.milestones.first.start_date + 1.day).rfc3339,
        course_identifier: "ecf-induction",
      }
    end

    let(:parsed_response) { JSON.parse(response.body) }

    before do
      travel_to ect_profile.schedule.milestones.first.start_date + 2.days
    end

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
        params = build_params(valid_params)
        expect { post "/api/v1/participant-declarations", params: params }
            .to change(ParticipantDeclaration, :count).by(1)
            .and change(ParticipantDeclarationAttempt, :count).by(1)
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
        expect(response.status).to eq 200
        expect(parsed_response["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      it "create payable declaration record when user is eligible" do
        params = build_params(valid_params)
        eligibility = ECFParticipantEligibility.create!(participant_profile_id: ect_profile.id)
        eligibility.eligible_status!
        post "/api/v1/participant-declarations", params: params
        expect(ParticipantDeclaration.order(:created_at).last.payable).to be_truthy
      end

      it "does not create duplicate declarations, but stores the duplicate declaration attempts" do
        params = build_params(valid_params)
        post "/api/v1/participant-declarations", params: params
        original_id = parsed_response["id"]

        expect { post "/api/v1/participant-declarations", params: params }
            .not_to change(ParticipantDeclaration, :count)
        expect { post "/api/v1/participant-declarations", params: params }
            .to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response.status).to eq 200
        expect(parsed_response["id"]).to eq(original_id)
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

      it "returns 422 when trying to create for an invalid user id" do
        # Expects the user uuid. Pass the early_career_teacher_profile_id
        invalid_user_id = valid_params.merge({ participant_id: ect_profile.id })
        post "/api/v1/participant-declarations", params: build_params(invalid_user_id)
        expect(response.status).to eq 422
      end

      it "returns 422 when trying to create with no id" do
        missing_user_id = valid_params.merge({ participant_id: "" })
        post "/api/v1/participant-declarations", params: build_params(missing_user_id)
        expect(response.status).to eq 422
      end

      it "returns 422 when a required parameter is missing" do
        missing_attribute = valid_params.except(:participant_id)
        post "/api/v1/participant-declarations", params: build_params(missing_attribute)
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: [I18n.t(:invalid_participant)] }.to_json)
      end

      it "returns 422 when supplied an incorrect course type" do
        incorrect_course_identifier = valid_params.merge({ course_identifier: "typoed-course-name" })
        post "/api/v1/participant-declarations", params: build_params(incorrect_course_identifier)
        expect(response.status).to eq 422
      end

      it "returns 422 when a participant type doesn't match the course type" do
        invalid_participant_for_course_type = valid_params.merge({ course_identifier: "ecf-mentor" })
        post "/api/v1/participant-declarations", params: build_params(invalid_participant_for_course_type)
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: [I18n.t(:invalid_participant)] }.to_json)
      end

      it "returns 422 when there are multiple errors" do
        post "/api/v1/participant-declarations", params: build_params("")
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: [I18n.t(:invalid_declaration_type)] }.to_json)
      end

      it "returns 400 when the data block is incorrect" do
        post "/api/v1/participant-declarations", params: {}.to_json
        expect(response.status).to eq 400
        expect(response.body).to eq({ bad_request: I18n.t(:invalid_data_structure) }.to_json)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        params = build_params(valid_params)
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v1/participant-declarations", params: params
        expect(response.status).to eq 401
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
      end
    end
  end

  describe "get" do
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    let(:participant_declaration) do
      create(:participant_declaration,
             user: ect_profile.user,
             cpd_lead_provider: cpd_lead_provider,
             course_identifier: "ecf-induction")
    end

    let!(:profile_declaration) do
      create(:profile_declaration,
             participant_declaration: participant_declaration,
             participant_profile: ect_profile)
    end

    context "when authorized" do
      context "when there is a non eligible declaration" do
        let(:expected_response) do
          {
            "data" =>
            [
              {
                "id" => participant_declaration.id,
                "type" => "participant_declaration",
                "attributes" => {
                  "participant_id" => ect_profile.user.id,
                  "declaration_type" => "started",
                  "declaration_date" => participant_declaration.declaration_date.rfc3339(3),
                  "course_identifier" => "ecf-induction",
                  "eligible_for_payment" => false,
                },
              },
            ],
          }
        end

        before do
          default_headers[:Authorization] = bearer_token
          default_headers[:CONTENT_TYPE] = "application/json"
        end

        it "loads list of eligible participant" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(JSON.parse(response.body)).to eq(expected_response)
        end
      end

      context "when there is an eligible declaration" do
        before do
          eligibility = ECFParticipantEligibility.create!(participant_profile_id: ect_profile.id)
          eligibility.eligible_status!
          participant_declaration.refresh_payability!
        end

        let(:expected_response) do
          {
            "data" =>
            [
              {
                "id" => participant_declaration.id,
                "type" => "participant_declaration",
                "attributes" => {
                  "participant_id" => ect_profile.user.id,
                  "declaration_type" => "started",
                  "declaration_date" => participant_declaration.declaration_date.rfc3339(3),
                  "course_identifier" => "ecf-induction",
                  "eligible_for_payment" => true,
                },
              },
            ],
          }
        end

        before do
          default_headers[:Authorization] = bearer_token
          default_headers[:CONTENT_TYPE] = "application/json"
        end

        it "loads list of eligible participant" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(JSON.parse(response.body)).to eq(expected_response)
        end
      end
    end
  end
end
