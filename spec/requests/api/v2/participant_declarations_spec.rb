# frozen_string_literal: true

require "rails_helper"

RSpec.describe "participant-declarations endpoint spec", :with_default_schedules, type: :request, with_feature_flags: { participant_outcomes_feature: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:started_milestone) { ect_profile.schedule.milestones.find_by(declaration_type: "started") }
  let(:declaration_date)  { started_milestone.start_date }
  let(:token)             { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token)      { "Bearer #{token}" }

  before do
    create(:ecf_statement, :output_fee, deadline_date: 2.weeks.from_now, cpd_lead_provider:)
  end

  def parsed_response
    JSON.parse(response.body)
  end

  describe "POST /api/v2/participant-declarations" do
    let(:ect_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
    let(:valid_params) do
      {
        participant_id: ect_profile.user.id,
        declaration_type: "started",
        declaration_date: declaration_date.rfc3339,
        course_identifier: "ecf-induction",
      }
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-declaration",
          attributes:,
        },
      }.to_json
    end

    context "when authorized" do
      let(:fake_logger) { double("logger", info: nil) }

      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      it "create declaration record and declaration attempt and return id when successful", :aggregate_failures do
        params = build_params(valid_params)
        expect { post "/api/v2/participant-declarations", params: }
          .to change(ParticipantDeclaration, :count).by(1)
                .and change(ParticipantDeclarationAttempt, :count).by(1)
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
        expect(response.status).to eq 200
        expect(parsed_response["data"]["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      context "when the participant is eligible" do
        let(:ect_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }

        it "create eligible declaration record when user is eligible" do
          params = build_params(valid_params)
          post "/api/v2/participant-declarations", params: params

          expect(ParticipantDeclaration.order(:created_at).last).to be_eligible
        end
      end

      it "does not create duplicate declarations with the same declaration date and stores the duplicate declaration attempts" do
        params = build_params(valid_params)
        post "/api/v2/participant-declarations", params: params

        expect {
          expect {
            post "/api/v2/participant-declarations", params:
          }.not_to change(ParticipantDeclaration, :count)
        }.to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response).not_to be_successful
        expect(parsed_response["errors"]).to eq(["title" => "base", "detail" => "There already exists a declaration that will be or has been paid for this event"])
      end

      it "does not create duplicate declarations with different declaration date and stores the duplicate declaration attempts" do
        params = build_params(valid_params)

        new_valid_params = valid_params
        new_valid_params[:declaration_date] = (ect_profile.schedule.milestones.first.start_date + 1.second).rfc3339

        params_with_different_declaration_date = build_params(new_valid_params)

        post "/api/v2/participant-declarations", params: params
        original_id = parsed_response["id"]

        expect { post "/api/v2/participant-declarations", params: }
          .not_to change(ParticipantDeclaration, :count)
        expect { post "/api/v2/participant-declarations", params: params_with_different_declaration_date }
          .to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["id"]).to eq(original_id)
      end

      it "logs passing schema validation" do
        allow(Rails).to receive(:logger).and_return(fake_logger)

        params = build_params(valid_params)

        post "/api/v2/participant-declarations", params: params

        expect(response.status).to eq 200
        expect(fake_logger).to have_received(:info).with("Passed schema validation").ordered
      end

      context "when lead provider has no access to the user" do
        let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:ect_profile)           { create(:ect, lead_provider: another_lead_provider.lead_provider) }

        it "create declaration attempt" do
          expect { post "/api/v2/participant-declarations", params: build_params(valid_params) }
            .to change(ParticipantDeclarationAttempt, :count).by(1)
        end

        it "does not create declaration" do
          expect { post "/api/v2/participant-declarations", params: build_params(valid_params) }
            .not_to change(ParticipantDeclaration, :count)
          expect(response.status).to eq 422
        end
      end

      context "when participant is withdrawn" do
        let(:ect_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }

        it "returns 200" do
          params = build_params(valid_params)
          post "/api/v2/participant-declarations", params: params
          expect(response.status).to eq 200
        end
      end

      context "when participant is deferred" do
        let(:ect_profile) do
          create(:ect, :deferred, lead_provider: cpd_lead_provider.lead_provider)
        end

        it "returns 200" do
          params = build_params(valid_params)
          post "/api/v2/participant-declarations", params: params
          expect(response.status).to eq 200
        end
      end

      it "returns 422 when trying to create for an invalid user id" do
        # Expects the user uuid. Pass the early_career_teacher_profile_id
        invalid_user_id = valid_params.merge({ participant_id: ect_profile.id })
        post "/api/v2/participant-declarations", params: build_params(invalid_user_id)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when trying to create with no id" do
        missing_user_id = valid_params.merge({ participant_id: "" })
        post "/api/v2/participant-declarations", params: build_params(missing_user_id)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when a required parameter is missing", :aggregation_failures do
        missing_attribute = valid_params.except(:participant_id)
        post "/api/v2/participant-declarations", params: build_params(missing_attribute)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to include(
            "title" => "participant_id",
            "detail" => "The property '#/participant_id' must be a valid Participant ID",
          )
      end

      it "ignores an unpermitted parameter" do
        post "/api/v2/participant-declarations", params: build_params(valid_params.merge(evidence_held: "test"))

        expect(response.status).to eq 200
        expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to be_nil
      end

      it "returns 422 when supplied an incorrect course type" do
        incorrect_course_identifier = valid_params.merge({ course_identifier: "typoed-course-name" })
        post "/api/v2/participant-declarations", params: build_params(incorrect_course_identifier)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when a participant type doesn't match the course type" do
        invalid_participant_for_course_type = valid_params.merge({ course_identifier: "ecf-mentor" })
        post "/api/v2/participant-declarations", params: build_params(invalid_participant_for_course_type)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to include(
            "title" => "course_identifier",
            "detail" => "The property '#/course_identifier' must be an available course to '#/participant_id'",
          )
      end

      it "returns 422 when there are multiple errors" do
        post "/api/v2/participant-declarations", params: build_params("")

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to eq(
            [
              { "title" => "declaration_date", "detail" => "can't be blank" },
              { "title" => "declaration_type", "detail" => "can't be blank" },
              { "title" => "participant_id", "detail" => "The property '#/participant_id' must be a valid Participant ID" },
              { "title" => "course_identifier", "detail" => "The property '#/course_identifier' must be an available course to '#/participant_id'" },
            ],
          )
      end

      it "returns 400 when the data block is incorrect" do
        post "/api/v2/participant-declarations", params: {}.to_json
        expect(response.status).to eq 400
        expect(response.body).to eq({ errors: [{ title: "Bad request", detail: I18n.t(:invalid_data_structure) }] }.to_json)
      end

      context "when it fails schema validation" do
        let(:params) { build_params(valid_params.merge(foo: "bar")) }

        it "logs info to rails logger" do
          allow(Rails).to receive(:logger).and_return(fake_logger)

          post "/api/v2/participant-declarations", params: params

          expect(response.status).to eql(200)
          expect(fake_logger).to have_received(:info).with("Failed schema validation for #{request.body.read}").ordered
          expect(fake_logger).to have_received(:info).with(instance_of(Array)).ordered
        end
      end

      context "when NPQ participant has completed declaration" do
        let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
        let(:schedule)              { NPQCourse.schedule_for(npq_course:) }
        let(:declaration_date)      { schedule.milestones.find_by(declaration_type:).start_date + 1.day }
        let(:npq_course) { create(:npq_leadership_course) }
        let(:participant_profile) do
          create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:)
        end
        let(:participant_id)    { participant_profile.user_id }
        let(:course_identifier) { npq_course.identifier }
        let(:declaration_type)  { "completed" }
        let(:has_passed) { nil }
        let(:params) do
          {
            data: {
              type: "participant-declaration",
              attributes: {
                participant_id:,
                declaration_type:,
                declaration_date: declaration_date.rfc3339,
                course_identifier:,
                has_passed:,
              },
            },
          }
        end

        before do
          create(:npq_leadership_schedule, cohort: Cohort.find_by(start_year: 2021))
          travel_to declaration_date
        end

        context "has_passed is true" do
          let(:has_passed)  { true }

          it "creates passed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v2/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(true)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end

        context "has_passed is false" do
          let(:has_passed)  { false }

          it "creates failed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v2/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(false)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        params = build_params(valid_params)
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v2/participant-declarations", params: params
        expect(response.status).to eq 401
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
      end
    end
  end

  describe "JSON Index Api" do
    let(:ect_profile)  { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
    let(:token)        { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token) { "Bearer #{token}" }

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
        let(:ect_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile)
        end

        let(:participant_declaration) do
          create(:ect_participant_declaration,
                 cpd_lead_provider:,
                 participant_profile: ect_profile)
        end

        before { participant_declaration }

        it "loads list of declarations" do
          get "/api/v2/participant-declarations"
          expect(response).to be_successful

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when there is an eligible declaration" do
        let(:ect_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }

        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile, state: "eligible")
        end

        before do
          participant_declaration

          default_headers[:Authorization] = bearer_token
          default_headers[:CONTENT_TYPE] = "application/json"
        end

        let(:participant_declaration) do
          create(:ect_participant_declaration,
                 cpd_lead_provider:,
                 participant_profile: ect_profile)
        end

        it "loads list of declarations" do
          get "/api/v2/participant-declarations"
          expect(response).to be_successful

          expect(parsed_response).to eq(expected_response)
        end

        context "when there is a voided declaration" do
          let(:expected_response) do
            expected_json_response(declaration: participant_declaration, profile: ect_profile, state: "voided")
          end

          let!(:participant_declaration) do
            create(:ect_participant_declaration, :voided, cpd_lead_provider:, participant_profile: ect_profile)
          end

          it "loads list of declarations", :aggregation_failures do
            get "/api/v2/participant-declarations"

            expect(response).to be_successful
            expect(parsed_response).to eq(expected_response)
          end
        end
      end

      context "when a updated since filter used" do
        before do
          travel_to 2.days.ago do
            create(:ect_participant_declaration, :voided, cpd_lead_provider:, participant_profile: ect_profile)
          end
        end

        it "returns declarations changed or created since a particular time", :aggregation_failures do
          get "/api/v2/participant-declarations", params: { filter: { updated_since: 1.day.ago.iso8601 } }

          expect(response).to be_successful
          expect(parsed_response["data"].size).to eq 0
        end
      end

      context "when a participant id filter used" do
        let!(:second_ect_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
        let!(:second_participant_declaration) do
          create(:ect_participant_declaration,
                 cpd_lead_provider:,
                 participant_profile: second_ect_profile)
        end
        let(:expected_response) do
          expected_json_response(declaration: second_participant_declaration, profile: second_ect_profile)
        end

        it "loads only declarations for the chosen participant id", :aggregation_failures do
          get "/api/v2/participant-declarations", params: { filter: { participant_id: second_ect_profile.user.id } }

          expect(response).to be_successful
          expect(parsed_response).to eq(expected_response)
        end

        it "does not load declaration for a non-existent participant id", :aggregation_failures do
          get "/api/v2/participant-declarations", params: { filter: { participant_id: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" } }

          expect(response.status).to eq 200
          expect(parsed_response).to eq({ "data" => [] })
        end
      end

      context "when querying a single participant declaration" do
        let(:expected_response) do
          expected_single_json_response(declaration: participant_declaration, profile: ect_profile, state: "eligible")
        end
        let(:participant_declaration) { create(:ect_participant_declaration, participant_profile: ect_profile, cpd_lead_provider:) }

        it "loads declaration with the specific id", :aggregation_failures do
          get "/api/v2/participant-declarations/#{participant_declaration.id}"

          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq(expected_response)
        end

        it "returns 404 if participant declaration does not exist", exceptions_app: true do
          get "/api/v2/participant-declarations/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe "CSV Index API" do
    let(:ect_profile)     { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
    let(:parsed_response) { CSV.parse(response.body, headers: true) }
    let(:token)           { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token)    { "Bearer #{token}" }

    let!(:participant_declaration_one) do
      create(:ect_participant_declaration, cpd_lead_provider:)
    end

    let!(:participant_declaration_two) do
      create(:ect_participant_declaration, cpd_lead_provider:)
    end

    before do
      default_headers[:Authorization] = bearer_token
      get "/api/v2/participant-declarations.csv"
    end

    it "returns the correct CSV content type header" do
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end

    it "returns all declarations" do
      expect(parsed_response.length).to eq(2)
    end

    it "returns the correct headers" do
      expect(parsed_response.headers).to match_array(
        %w[id course_identifier declaration_date declaration_type participant_id state updated_at has_passed],
      )
    end

    it "returns the correct values" do
      participant_declaration_one_row = parsed_response.find { |row| row["id"] == participant_declaration_one.id }
      expect(participant_declaration_one_row).not_to be_nil
      expect(participant_declaration_one_row["course_identifier"]).to eql participant_declaration_one.course_identifier
      expect(participant_declaration_one_row["declaration_date"]).to eql participant_declaration_one.declaration_date.rfc3339
      expect(participant_declaration_one_row["declaration_type"]).to eql participant_declaration_one.declaration_type
      expect(participant_declaration_one_row["state"]).to eql participant_declaration_one.state.to_s
      expect(participant_declaration_one_row["participant_id"]).to eql participant_declaration_one.participant_profile.user.id
      expect(participant_declaration_one_row["updated_at"]).to eql participant_declaration_one.updated_at.rfc3339
    end

    it "ignores pagination parameters" do
      get "/api/v2/participant-declarations.csv", params: { page: { per_page: 1, page: 1 } }
      expect(parsed_response.length).to eq(2)
    end
  end

  describe "PUT /api/v2/participant-declarations/:id/void" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "when declaration is submitted" do
      let(:declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }

      it "can be voided" do
        expect {
          put "/api/v2/participant-declarations/#{declaration.id}/void"
        }.to change { declaration.reload.state }.from("submitted").to("voided")
      end

      it "returns a 200" do
        put "/api/v2/participant-declarations/#{declaration.id}/void"
        expect(response.status).to eql(200)
      end
    end

    context "when declaration is payable" do
      let(:declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }

      it "can be voided" do
        expect {
          put "/api/v2/participant-declarations/#{declaration.id}/void"
        }.to change { declaration.reload.state }.from("payable").to("voided")
      end

      it "returns a 200" do
        put "/api/v2/participant-declarations/#{declaration.id}/void"
        expect(response.status).to eql(200)
      end
    end
  end

private

  def expected_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil)
    {
      "data" =>
      [
        single_json_declaration(declaration:, profile:, course_identifier:, state:, has_passed:),
      ],
    }
  end

  def expected_single_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil)
    {
      "data" =>
      single_json_declaration(declaration:, profile:, course_identifier:, state:, has_passed:),
    }
  end

  def single_json_declaration(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil)
    {
      "id" => declaration.id,
      "type" => "participant-declaration",
      "attributes" => {
        "participant_id" => profile.user.id,
        "declaration_type" => "started",
        "declaration_date" => declaration.declaration_date.rfc3339,
        "course_identifier" => course_identifier,
        "state" => state,
        "updated_at" => declaration.updated_at.rfc3339,
        "has_passed" => has_passed,
      },
    }
  end
end
