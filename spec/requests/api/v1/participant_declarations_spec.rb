# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe "participant-declarations endpoint spec", type: :request do
  include_context "lead provider profiles and courses"
  let(:parsed_response) { JSON.parse(response.body) }

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
        expect(parsed_response["data"]["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      it "create payable declaration record when user is eligible" do
        params = build_params(valid_params)
        eligibility = ECFParticipantEligibility.create!(participant_profile_id: ect_profile.id)
        eligibility.eligible_status!
        post "/api/v1/participant-declarations", params: params
        expect(ParticipantDeclaration.order(:created_at).last.payable).to be_truthy
      end

      it "does not create duplicate declarations with the same declaration date, but stores the duplicate declaration attempts" do
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

      it "does not create duplicate declarations with different declaration date, but stores the duplicate declaration attempts" do
        params = build_params(valid_params)

        new_valid_params = valid_params
        new_valid_params[:declaration_date] = (ect_profile.schedule.milestones.first.start_date + 1.second).rfc3339

        params_with_different_declaration_date = build_params(new_valid_params)

        post "/api/v1/participant-declarations", params: params
        original_id = parsed_response["id"]

        expect { post "/api/v1/participant-declarations", params: params }
            .not_to change(ParticipantDeclaration, :count)
        expect { post "/api/v1/participant-declarations", params: params_with_different_declaration_date }
            .to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response.status).to eq 400
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
        expect(response.body).to eq({ errors: [{ title: "Bad or missing parameters", detail: I18n.t("activemodel.errors.models.record_declarations/base.attributes.participant_id.blank") }] }.to_json)
      end

      it "returns 422 when sending an unpermitted parameter" do
        missing_attribute = valid_params.merge(evidence_held: "test")
        post "/api/v1/participant-declarations", params: build_params(missing_attribute)
        expect(response.status).to eq 422
        expect(response.body).to eq({ errors: [{ title: "Unpermitted parameters", detail: "Unpermitted parameter: evidence_held" }] }.to_json)
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
        expect(response.body).to eq({ errors: [{ title: "Bad or missing parameters", detail: I18n.t(:invalid_participant) }] }.to_json)
      end

      it "returns 422 when there are multiple errors" do
        post "/api/v1/participant-declarations", params: build_params("")
        expect(response.status).to eq 422
        expect(response.body).to eq({ errors: [{ title: "Bad or missing parameters", detail: I18n.t(:invalid_declaration_type) }] }.to_json)
      end

      it "returns 400 when the data block is incorrect" do
        post "/api/v1/participant-declarations", params: {}.to_json
        expect(response.status).to eq 400
        expect(response.body).to eq({ errors: [{ title: "Bad request", detail: I18n.t(:invalid_data_structure) }] }.to_json)
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

  describe "JSON Index Api" do
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

    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      context "when there is a non eligible declaration" do
        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile)
        end

        it "loads list of eligible participant" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when there is an eligible declaration" do
        before do
          eligibility = ECFParticipantEligibility.create!(participant_profile_id: ect_profile.id)
          eligibility.eligible_status!
          participant_declaration.refresh_payability!
        end

        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile, eligible_for_payment: true)
        end

        it "loads list of eligible participants" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when a updated since filter used" do
        it "returns declarations changed or created since a particular time" do
          participant_declaration.update!(updated_at: 2.days.ago)
          get "/api/v1/participant-declarations", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(response.status).to eq 200

          expect(parsed_response["data"].size).to eq 0
        end
      end

      context "when a participant id filter used" do
        let!(:second_ect_profile) { create(:participant_profile, :ect, schedule: default_schedule) }
        let!(:second_participant_declaration) do
          create(:participant_declaration,
                 user: second_ect_profile.user,
                 cpd_lead_provider: cpd_lead_provider,
                 course_identifier: "ecf-induction")
        end
        let!(:second_profile_declaration) do
          create(:profile_declaration,
                 participant_declaration: second_participant_declaration,
                 participant_profile: second_ect_profile)
        end
        let(:expected_response) do
          expected_json_response(declaration: second_participant_declaration, profile: second_ect_profile)
        end

        it "loads only declarations for the chosen participant id" do
          get "/api/v1/participant-declarations", params: { filter: { participant_id: second_ect_profile.user.id } }
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end

        it "does not load declaration for a non-existent participant id" do
          get "/api/v1/participant-declarations", params: { filter: { participant_id: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" } }
          expect(response.status).to eq 200

          expect(parsed_response).to eq({ "data" => [] })
        end
      end

      context "when querying a single participant declaration" do
        let(:expected_response) do
          expected_single_json_response(declaration: participant_declaration, profile: ect_profile)
        end

        it "loads declaration with the specific id" do
          get "/api/v1/participant-declarations/#{participant_declaration.id}"
          expect(response.status).to eq 200

          expect(JSON.parse(response.body)).to eq(expected_response)
        end

        it "returns 404 if participant declaration does not exist" do
          get "/api/v1/participant-declarations/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe "CSV Index API" do
    let(:parsed_response) { CSV.parse(response.body, headers: true) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    let!(:participant_declaration_one) do
      participant_declaration = create(:participant_declaration,
                                       user: ect_profile.user,
                                       cpd_lead_provider: cpd_lead_provider,
                                       course_identifier: "ecf-induction")
      create(:profile_declaration,
             participant_declaration: participant_declaration,
             participant_profile: ect_profile)
      participant_declaration
    end

    let!(:participant_declaration_two) do
      participant_declaration = create(:participant_declaration,
                                       user: ect_profile.user,
                                       cpd_lead_provider: cpd_lead_provider,
                                       course_identifier: "ecf-induction")
      create(:profile_declaration,
             participant_declaration: participant_declaration,
             participant_profile: ect_profile)
      participant_declaration
    end

    before do
      default_headers[:Authorization] = bearer_token
      get "/api/v1/participant-declarations.csv"
    end

    it "returns the correct CSV content type header" do
      expect(response.headers["Content-Type"]).to eql("text/csv")
    end

    it "returns all declarations" do
      expect(parsed_response.length).to eql 2
    end

    it "returns the correct headers" do
      expect(parsed_response.headers).to match_array(
        %w[id course_identifier declaration_date declaration_type eligible_for_payment participant_id],
      )
    end

    it "returns the correct values" do
      participant_declaration_one_row = parsed_response.find { |row| row["id"] == participant_declaration_one.id }
      expect(participant_declaration_one_row).not_to be_nil
      expect(participant_declaration_one_row["course_identifier"]).to eql participant_declaration_one.course_identifier
      expect(participant_declaration_one_row["declaration_date"]).to eql participant_declaration_one.declaration_date.rfc3339
      expect(participant_declaration_one_row["declaration_type"]).to eql participant_declaration_one.declaration_type
      expect(participant_declaration_one_row["eligible_for_payment"]).to eql participant_declaration_one.payable.to_s
      expect(participant_declaration_one_row["participant_id"]).to eql participant_declaration_one.participant_profile.user.id
    end

    it "ignores pagination parameters" do
      get "/api/v1/participants.csv", params: { page: { per_page: 1, page: 1 } }
      expect(parsed_response.length).to eql 2
    end
  end

private

  def expected_json_response(declaration:, profile:, course_identifier: "ecf-induction", eligible_for_payment: false)
    {
      "data" =>
          [
            single_json_declaration(declaration: declaration, profile: profile, course_identifier: course_identifier, eligible_for_payment: eligible_for_payment),
          ],
    }
  end

  def expected_single_json_response(declaration:, profile:, course_identifier: "ecf-induction", eligible_for_payment: false)
    {
      "data" =>
          single_json_declaration(declaration: declaration, profile: profile, course_identifier: course_identifier, eligible_for_payment: eligible_for_payment),
    }
  end

  def single_json_declaration(declaration:, profile:, course_identifier: "ecf-induction", eligible_for_payment: false)
    {
      "id" => declaration.id,
      "type" => "participant-declaration",
      "attributes" => {
        "participant_id" => profile.user.id,
        "declaration_type" => "started",
        "declaration_date" => declaration.declaration_date.rfc3339,
        "course_identifier" => course_identifier,
        "eligible_for_payment" => eligible_for_payment,
      },
    }
  end
end
