# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Participant Declarations", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  describe "#index" do
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider1) }

    let(:cohort1) { Cohort.current || create(:cohort, :current) }
    let(:cohort2) { Cohort.previous || create(:cohort, :previous) }

    let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider1) { cpd_lead_provider1.lead_provider }
    let(:school_cohort1) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider1, cohort: cohort1) }
    let(:school_cohort2) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider1, cohort: cohort2) }
    let(:participant_profile1) { create(:ect, :eligible_for_funding, school_cohort: school_cohort1, lead_provider: lead_provider1) }
    let(:participant_profile2) { create(:ect, :eligible_for_funding, school_cohort: school_cohort1, lead_provider: lead_provider1) }
    let(:participant_profile3) { create(:ect, :eligible_for_funding, school_cohort: school_cohort2, lead_provider: lead_provider1) }

    let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider2) { cpd_lead_provider2.lead_provider }
    let(:school_cohort3) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider2, cohort: cohort2) }
    let(:participant_profile4) { create(:ect, :eligible_for_funding, school_cohort: school_cohort3, lead_provider: lead_provider1) }

    let(:delivery_partner1) { create(:delivery_partner) }
    let(:delivery_partner2) { create(:delivery_partner) }

    let!(:participant_declaration1) do
      create(
        :ect_participant_declaration,
        :paid,
        uplifts: [:sparsity_uplift],
        declaration_type: "started",
        evidence_held: "training-event-attended",
        created_at: 3.days.ago,
        updated_at: 3.days.ago,

        cpd_lead_provider: cpd_lead_provider1,
        participant_profile: participant_profile1,
        delivery_partner: delivery_partner1,
      )
    end
    let!(:participant_declaration2) do
      create(
        :ect_participant_declaration,
        :eligible,
        declaration_type: "started",
        created_at: 1.day.ago,
        updated_at: 1.day.ago,

        cpd_lead_provider: cpd_lead_provider1,
        participant_profile: participant_profile2,
        delivery_partner: delivery_partner2,
      )
    end
    let!(:participant_declaration3) do
      create(
        :ect_participant_declaration,
        :eligible,
        declaration_type: "started",
        created_at: 5.days.ago,
        updated_at: 5.days.ago,

        cpd_lead_provider: cpd_lead_provider1,
        participant_profile: participant_profile3,
        delivery_partner: delivery_partner2,
      )
    end
    let!(:participant_declaration4) do
      create(
        :ect_participant_declaration,
        :eligible,
        declaration_type: "started",
        created_at: 5.days.ago,
        updated_at: 5.days.ago,

        cpd_lead_provider: cpd_lead_provider2,
        participant_profile: participant_profile4,
        delivery_partner: delivery_partner1,
      )
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/participant-declarations"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/participant-declarations"

        expect(response.status).to eq(403)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v3/participant-declarations"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns all participant declarations" do
        get "/api/v3/participant-declarations"

        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns correct type" do
        get "/api/v3/participant-declarations"

        expect(parsed_response["data"][0]).to have_type("participant-declaration")
      end

      it "returns IDs" do
        get "/api/v3/participant-declarations"
        participant_declaration_ids = [participant_declaration1, participant_declaration2, participant_declaration3].map(&:id)
        expect(parsed_response["data"][0]["id"]).to be_in(participant_declaration_ids)
      end

      it "has correct attributes" do
        get "/api/v3/participant-declarations"

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(
          :participant_id,
          :declaration_type,
          :declaration_date,
          :course_identifier,
          :state,
          :updated_at,
          :created_at,
          :delivery_partner_id,
          :statement_id,
          :clawback_statement_id,
          :ineligible_for_funding_reason,
          :mentor_id,
          :uplift_paid,
          :evidence_held,
          :has_passed,
        ).exactly
      end

      it "returns the right number of participant declarations per page" do
        get "/api/v3/participant-declarations", params: { page: { per_page: 1, page: 1 } }

        expect(parsed_response["data"].size).to eql(1)
      end

      context "when filtering by cohort" do
        it "returns all participant declarations for one" do
          get "/api/v3/participant-declarations", params: { filter: { cohort: cohort2.display_name } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration3.id)
        end

        it "returns all participant declarations for many" do
          get "/api/v3/participant-declarations", params: { filter: { cohort: [cohort1.display_name, cohort2.display_name].join(",") } }

          expect(parsed_response["data"].size).to eql(3)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration3.id)
          expect(parsed_response.dig("data", 1, "id")).to eql(participant_declaration1.id)
          expect(parsed_response.dig("data", 2, "id")).to eql(participant_declaration2.id)
        end

        it "returns no participant declarations if no matches" do
          get "/api/v3/participant-declarations", params: { filter: { cohort: "3100" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when filtering by participant_id" do
        it "returns all participant declarations for one" do
          get "/api/v3/participant-declarations", params: { filter: { participant_id: participant_profile1.user_id } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration1.id)
        end

        it "returns all participant declarations for many" do
          get "/api/v3/participant-declarations", params: { filter: { participant_id: [participant_profile1.user_id, participant_profile2.user_id].join(",") } }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration1.id)
          expect(parsed_response.dig("data", 1, "id")).to eql(participant_declaration2.id)
        end

        it "returns no participant declarations if no matches" do
          get "/api/v3/participant-declarations", params: { filter: { participant_id: "does_not_exist" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when filtering by updated_since" do
        before do
          participant_declaration1.update!(updated_at: 3.days.ago)
          participant_declaration2.update!(updated_at: 1.day.ago)
          participant_declaration3.update!(updated_at: 5.days.ago)
          participant_declaration4.update!(updated_at: 6.days.ago)
        end

        it "returns participant declarations updated after updated_since" do
          get "/api/v3/participant-declarations", params: { filter: { updated_since: 2.days.ago.iso8601 } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration2.id)
        end
      end

      context "when filtering by delivery_partner_id" do
        it "returns all participant declarations for one" do
          get "/api/v3/participant-declarations", params: { filter: { delivery_partner_id: delivery_partner2.id } }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration3.id)
          expect(parsed_response.dig("data", 1, "id")).to eql(participant_declaration2.id)
        end

        it "returns all participant declarations for many" do
          get "/api/v3/participant-declarations", params: { filter: { delivery_partner_id: [delivery_partner1.id, delivery_partner2.id].join(",") } }

          expect(parsed_response["data"].size).to eql(3)
          expect(parsed_response.dig("data", 0, "id")).to eql(participant_declaration3.id)
          expect(parsed_response.dig("data", 1, "id")).to eql(participant_declaration1.id)
          expect(parsed_response.dig("data", 2, "id")).to eql(participant_declaration2.id)
        end

        it "returns no participant declarations if no matches" do
          get "/api/v3/participant-declarations", params: { filter: { delivery_partner_id: "does_not_exist" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end
    end
  end

  describe "#create" do
    let(:started_milestone) { ect_profile.schedule.milestones.find_by(declaration_type: "started") }
    let(:declaration_date)  { started_milestone.start_date }
    let(:ect_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
    let(:valid_params) do
      {
        participant_id: ect_profile.user.id,
        declaration_type: "started",
        declaration_date: declaration_date.rfc3339,
        course_identifier: "ecf-induction",
      }
    end

    before do
      create(:ecf_statement, :output_fee, deadline_date: 2.weeks.from_now, cpd_lead_provider:)
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-declaration",
          attributes:,
        },
      }.to_json
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        params = build_params(valid_params)
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post("/api/v3/participant-declarations", params:)
        expect(response.status).to eq 401
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
      end
    end

    context "when authorized" do
      let(:fake_logger) { double("logger", info: nil) }

      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      it "create declaration record and declaration attempt and return id when successful", :aggregate_failures do
        params = build_params(valid_params)
        expect { post "/api/v3/participant-declarations", params: }
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
          post("/api/v3/participant-declarations", params:)

          expect(ParticipantDeclaration.order(:created_at).last).to be_eligible
        end
      end

      it "does not create duplicate declarations with the same declaration date and stores the duplicate declaration attempts" do
        params = build_params(valid_params)
        post("/api/v3/participant-declarations", params:)

        expect {
          expect {
            post "/api/v3/participant-declarations", params:
          }.not_to change(ParticipantDeclaration, :count)
        }.to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response).not_to be_successful
        expect(parsed_response["errors"]).to eq(["title" => "base", "detail" => "A declaration has already been submitted that will be, or has been, paid for this event"])
      end

      it "does not create duplicate declarations with different declaration date and stores the duplicate declaration attempts" do
        params = build_params(valid_params)

        new_valid_params = valid_params
        new_valid_params[:declaration_date] = (ect_profile.schedule.milestones.first.start_date + 1.second).rfc3339

        params_with_different_declaration_date = build_params(new_valid_params)

        post("/api/v3/participant-declarations", params:)
        original_id = parsed_response["id"]

        expect { post "/api/v3/participant-declarations", params: }
          .not_to change(ParticipantDeclaration, :count)
        expect { post "/api/v3/participant-declarations", params: params_with_different_declaration_date }
          .to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["id"]).to eq(original_id)
      end

      it "logs passing schema validation" do
        allow(Rails).to receive(:logger).and_return(fake_logger)

        params = build_params(valid_params)

        post("/api/v3/participant-declarations", params:)

        expect(response.status).to eq 200
        expect(fake_logger).to have_received(:info).with("Passed schema validation").ordered
      end

      context "when lead provider has no access to the user" do
        let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:ect_profile)           { create(:ect, lead_provider: another_lead_provider.lead_provider) }

        it "create declaration attempt" do
          expect { post "/api/v3/participant-declarations", params: build_params(valid_params) }
            .to change(ParticipantDeclarationAttempt, :count).by(1)
        end

        it "does not create declaration" do
          expect { post "/api/v3/participant-declarations", params: build_params(valid_params) }
            .not_to change(ParticipantDeclaration, :count)
          expect(response.status).to eq 422
        end
      end

      context "when participant is withdrawn" do
        let(:ect_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }

        it "returns 200" do
          params = build_params(valid_params)
          post("/api/v3/participant-declarations", params:)
          expect(response.status).to eq 200
        end
      end

      context "when participant is deferred" do
        let(:ect_profile) do
          create(:ect, :deferred, lead_provider: cpd_lead_provider.lead_provider)
        end

        it "returns 200" do
          params = build_params(valid_params)
          post("/api/v3/participant-declarations", params:)
          expect(response.status).to eq 200
        end
      end

      it "returns 422 when trying to create for an invalid user id" do
        # Expects the user uuid. Pass the early_career_teacher_profile_id
        invalid_user_id = valid_params.merge({ participant_id: ect_profile.id })
        post "/api/v3/participant-declarations", params: build_params(invalid_user_id)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when trying to create with no id" do
        missing_user_id = valid_params.merge({ participant_id: "" })
        post "/api/v3/participant-declarations", params: build_params(missing_user_id)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when a required parameter is missing", :aggregation_failures do
        missing_attribute = valid_params.except(:participant_id)
        post "/api/v3/participant-declarations", params: build_params(missing_attribute)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to include(
            "title" => "participant_id",
            "detail" => "The property '#/participant_id' must be a valid Participant ID",
          )
      end

      it "ignores an unpermitted parameter" do
        post "/api/v3/participant-declarations", params: build_params(valid_params.merge(evidence_held: "test"))

        expect(response.status).to eq 200
        expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to eq("test")
      end

      it "returns 422 when supplied an incorrect course type" do
        incorrect_course_identifier = valid_params.merge({ course_identifier: "typoed-course-name" })
        post "/api/v3/participant-declarations", params: build_params(incorrect_course_identifier)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when a participant type doesn't match the course type" do
        invalid_participant_for_course_type = valid_params.merge({ course_identifier: "ecf-mentor" })
        post "/api/v3/participant-declarations", params: build_params(invalid_participant_for_course_type)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to include(
            "title" => "course_identifier",
            "detail" => "The property '#/course_identifier' must be an available course to '#/participant_id'",
          )
      end

      it "returns 422 when there are multiple errors" do
        post "/api/v3/participant-declarations", params: build_params("")

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"])
          .to eq(
            [
              { "title" => "declaration_date", "detail" => "The property '#/declaration_date' must be present" },
              { "title" => "declaration_type", "detail" => "The property '#/declaration_type' must be present" },
              { "title" => "participant_id", "detail" => "The property '#/participant_id' must be a valid Participant ID" },
              { "title" => "course_identifier", "detail" => "The property '#/course_identifier' must be an available course to '#/participant_id'" },
            ],
          )
      end

      it "returns 400 when the data block is incorrect" do
        post "/api/v3/participant-declarations", params: {}.to_json
        expect(response.status).to eq 400
        expect(response.body).to eq({ errors: [{ title: "Bad request", detail: I18n.t(:invalid_data_structure) }] }.to_json)
      end

      context "when it fails schema validation" do
        let(:params) { build_params(valid_params.merge(foo: "bar")) }

        it "logs info to rails logger" do
          allow(Rails).to receive(:logger).and_return(fake_logger)

          post("/api/v3/participant-declarations", params:)

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
          travel_to declaration_date
        end

        context "has_passed is true" do
          let(:has_passed) { true }

          it "creates passed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v3/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(true)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end

        context "has_passed is false" do
          let(:has_passed) { false }

          it "creates failed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v3/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(false)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end
      end
    end
  end

  describe "#show" do
    let(:participant_declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/participant-declarations/#{participant_declaration.id}"

        expect(response.status).to eq(401)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v3/participant-declarations/#{participant_declaration.id}"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns correct type" do
        get "/api/v3/participant-declarations/#{participant_declaration.id}"

        expect(parsed_response["data"]).to have_type("participant-declaration")
      end

      it "has correct attributes" do
        get "/api/v3/participant-declarations/#{participant_declaration.id}"

        expect(parsed_response["data"]["id"]).to eql(participant_declaration.id)
        expect(parsed_response["data"]).to have_jsonapi_attributes(
          :participant_id,
          :declaration_type,
          :declaration_date,
          :course_identifier,
          :state,
          :updated_at,
          :created_at,
          :delivery_partner_id,
          :statement_id,
          :clawback_statement_id,
          :ineligible_for_funding_reason,
          :mentor_id,
          :uplift_paid,
          :evidence_held,
          :has_passed,
        ).exactly
      end

      it "returns a 200" do
        get "/api/v3/participant-declarations/#{participant_declaration.id}"

        expect(response.status).to eql(200)
      end
    end
  end

  describe "#void" do
    context "when unauthorized" do
      let(:participant_declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        put "/api/v3/participant-declarations/#{participant_declaration.id}/void"

        expect(response.status).to eq(401)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      context "when declaration is submitted" do
        let(:participant_declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }

        it "returns correct jsonapi content type header" do
          put "/api/v3/participant-declarations/#{participant_declaration.id}/void"

          expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
        end

        it "returns correct type" do
          put "/api/v3/participant-declarations/#{participant_declaration.id}/void"

          expect(parsed_response["data"]).to have_type("participant-declaration")
        end

        it "has correct attributes" do
          put "/api/v3/participant-declarations/#{participant_declaration.id}/void"

          expect(parsed_response["data"]).to have_jsonapi_attributes(
            :participant_id,
            :declaration_type,
            :declaration_date,
            :course_identifier,
            :state,
            :updated_at,
            :created_at,
            :delivery_partner_id,
            :statement_id,
            :clawback_statement_id,
            :ineligible_for_funding_reason,
            :mentor_id,
            :uplift_paid,
            :evidence_held,
            :has_passed,
          ).exactly
        end

        it "can be voided" do
          expect {
            put "/api/v3/participant-declarations/#{participant_declaration.id}/void"
          }.to change { participant_declaration.reload.state }.from("submitted").to("voided")
        end

        it "returns a 200" do
          put "/api/v3/participant-declarations/#{participant_declaration.id}/void"
          expect(response.status).to eql(200)
        end
      end

      context "when declaration is payable" do
        let(:participant_declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }

        it "can be voided" do
          expect {
            put "/api/v3/participant-declarations/#{participant_declaration.id}/void"
          }.to change { participant_declaration.reload.state }.from("payable").to("voided")
        end

        it "returns a 200" do
          put "/api/v3/participant-declarations/#{participant_declaration.id}/void"
          expect(response.status).to eql(200)
        end
      end
    end
  end
end
