# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe "participant-declarations endpoint spec", type: :request do
  include_context "lead provider profiles and courses"
  let(:parsed_response) { JSON.parse(response.body) }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:milestone_start_date) { ect_profile.schedule.milestones.find_by(declaration_type: "started").start_date }
  describe "POST /api/v1/participant-declarations" do
    let(:valid_params) do
      {
        participant_id: ect_profile.user.id,
        declaration_type: "started",
        declaration_date: milestone_start_date.rfc3339,
        course_identifier: "ecf-induction",
      }
    end

    before do
      travel_to milestone_start_date + 2.days
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
        create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
      end

      context "when posting for the new cohort" do
        let(:school)              { create(:school) }
        let(:next_cohort)         { create(:cohort, :next) }
        let(:next_school_cohort)  { create(:school_cohort, school:, cohort: next_cohort) }
        let(:next_schedule)       { create(:schedule, name: "ECF September 2022", cohort: next_cohort).tap { |schedule| create(:milestone, schedule:, start_date: Date.new(2022, 9, 1), declaration_type: "started", milestone_date: Date.new(2022, 11, 30)) } }
        let(:next_partnership)    { create(:partnership, school:, lead_provider: cpd_lead_provider.lead_provider, cohort: next_cohort, delivery_partner:) }
        let(:induction_programme) { create(:induction_programme, :fip, partnership: next_partnership) }
        let(:ect_profile)         { create(:ect_participant_profile, :ecf_participant_eligibility, schedule: next_schedule) }

        before do
          Induction::Enrol.call(participant_profile: ect_profile, induction_programme:)
          create(:ecf_statement, cohort: next_cohort, output_fee: true, deadline_date: next_schedule.milestones.first.milestone_date, cpd_lead_provider:)
        end

        it "create declaration record and declaration attempt and return id when successful" do
          params = {
            participant_id: ect_profile.user_id,
            declaration_date: ect_profile.schedule.milestones.first.start_date.rfc3339,
            declaration_type: "started",
            course_identifier: "ecf-induction",
          }

          post "/api/v1/participant-declarations", params: build_params(params)

          declaration = ParticipantDeclaration::ECF.find(JSON.parse(response.body).dig("data", "id"))
          expect(declaration.participant_profile.schedule).to eq(next_schedule)
          expect(declaration.statements.first.cohort).to eq(next_cohort)
        end
      end

      it "create declaration record and declaration attempt and return id when successful" do
        params = build_params(valid_params)
        expect { post "/api/v1/participant-declarations", params: }.to change(ParticipantDeclaration, :count).by(1).and change(ParticipantDeclarationAttempt, :count).by(1)
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_s)
        expect(response.status).to eq 200
        expect(parsed_response["data"]["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      it "create eligible declaration record when user is eligible" do
        eligibility = ECFParticipantEligibility.create!(participant_profile_id: ect_profile.id)
        eligibility.eligible_status!
        params = build_params(valid_params)
        post "/api/v1/participant-declarations", params: params

        expect(ParticipantDeclaration.order(:created_at).last).to be_eligible
      end

      it "does not create duplicate declarations with the same declaration date" do
        params = build_params(valid_params)
        post "/api/v1/participant-declarations", params: params
        original_id = parsed_response["id"]

        expect { post "/api/v1/participant-declarations", params: }
            .not_to change(ParticipantDeclaration, :count)

        expect(response.status).to eq 422
        expect(parsed_response["id"]).to eq(original_id)
      end

      it "does not create duplicate declarations with different declaration date" do
        params = build_params(valid_params)

        new_valid_params = valid_params
        new_valid_params[:declaration_date] = (milestone_start_date + 1.second).rfc3339

        params_with_different_declaration_date = build_params(new_valid_params)

        post "/api/v1/participant-declarations", params: params
        original_id = parsed_response["id"]

        expect { post "/api/v1/participant-declarations", params: params_with_different_declaration_date }
            .not_to change(ParticipantDeclaration, :count)

        expect(response.status).to eq 422
        expect(parsed_response["id"]).to eq(original_id)
      end

      it "logs passing schema validation" do
        allow(Rails).to receive(:logger).and_return(fake_logger)

        params = build_params(valid_params)

        post "/api/v1/participant-declarations", params: params

        expect(response.status).to eq 200
        expect(fake_logger).to have_received(:info).with("Passed schema validation").ordered
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

      context "when participant is withdrawn" do
        before do
          ect_profile.participant_profile_states.create({ state: "withdrawn", created_at: milestone_start_date - 1.second })
        end

        it "returns 200" do
          params = build_params(valid_params)
          post "/api/v1/participant-declarations", params: params
          expect(response.status).to eq 200
        end
      end

      context "when participant is deferred" do
        before do
          ect_profile.participant_profile_states.create({ state: "deferred", created_at: milestone_start_date - 1.second })
        end

        it "returns 200" do
          params = build_params(valid_params)
          post "/api/v1/participant-declarations", params: params
          expect(response.status).to eq 200
        end
      end

      context "when the participant transfers to a new school with a different lead provider" do
        let(:new_programme) { create(:induction_programme, :fip) }
        let(:transfer_lp_token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: new_programme.partnership.lead_provider.cpd_lead_provider) }
        let(:transfer_lp_bearer_token) { "Bearer #{transfer_lp_token}" }
        let(:url) { "/api/v1/participants/ecf/#{ect_profile.user.id}/withdraw" }
        let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }

        context "when the participant has been withdrawn" do
          before do
            induction_record.leaving!(milestone_start_date + 1)
            Induction::Enrol.call(participant_profile: ect_profile, induction_programme: new_programme, start_date: milestone_start_date)
            put url, params: build_params(params)
            ParticipantProfileState.create!(participant_profile: ect_profile, state: ParticipantProfileState.states[:withdrawn], cpd_lead_provider:)
          end

          it "is possible for new lead provider to post a declaration" do
            default_headers[:Authorization] = transfer_lp_bearer_token
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200
          end

          it "is possible for previous lead provider to submit backdated declarations" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 1).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200
          end

          it "is not possible for previous lead provider to submit a declaration after withdrawal date" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 422
            expect(response.body).to include("Declaration must be before withdrawal date")
          end

          it "is not possible for previous lead provider to view future declarations" do
            default_headers[:Authorization] = transfer_lp_bearer_token

            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200

            default_headers[:Authorization] = bearer_token
            expect { get "/api/v1/participant-declarations/#{ect_profile.participant_declarations.first.id}" }
              .to raise_error(ActiveRecord::RecordNotFound)
          end

          it "is not possible for new lead provider to post same declaration_type as previous lead_provider" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 1).rfc3339 })

            post "/api/v1/participant-declarations", params: build_params(updated_params)
            expect(response.status).to eq 200

            default_headers[:Authorization] = transfer_lp_bearer_token
            new_updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(new_updated_params)

            expect(response.status).to eq 422
            expect(response.body).to include("There already exists a declaration that will be or has been paid for this event")
          end
        end

        context "when the participant has not been withdrawn" do
          before do
            induction_record.leaving!(ect_profile.schedule.milestones.first.start_date + 1)
            Induction::Enrol.call(participant_profile: ect_profile, induction_programme: new_programme, start_date: milestone_start_date)
            put url, params: build_params(params)
          end

          it "is possible for new lead provider to post a declaration" do
            default_headers[:Authorization] = transfer_lp_bearer_token

            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200
          end

          it "is possible for previous lead provider to submit backdated declarations" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 1).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200
          end

          it "is not possible for the previous lead provider to view future declarations" do
            default_headers[:Authorization] = transfer_lp_bearer_token

            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })
            post "/api/v1/participant-declarations", params: build_params(updated_params)

            expect(response.status).to eq 200

            default_headers[:Authorization] = bearer_token
            expect { get "/api/v1/participant-declarations/#{ect_profile.participant_declarations.first.id}" }
              .to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when the participant transfers to a new school with the same lead provider" do
        let(:partnership) { create(:partnership, school:, lead_provider: ecf_lead_provider, delivery_partner:, cohort: ect_profile.cohort) }
        let(:school) { create(:school, name: "Transferred-to School") }
        let(:programme) { create(:induction_programme, :fip, school_cohort:) }
        let(:url) { "/api/v1/participants/ecf/#{ect_profile.user.id}/withdraw" }
        let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }

        context "when the participant has been withdrawn" do
          before do
            induction_record.leaving!(milestone_start_date + 1)
            Induction::Enrol.call(participant_profile: ect_profile, induction_programme: programme, start_date: milestone_start_date)
            put url, params: build_params(params)
            ParticipantProfileState.create!(participant_profile: ect_profile, state: ParticipantProfileState.states[:withdrawn], cpd_lead_provider:)
          end

          it "is possible for the same lead provider to post a declaration" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })

            post "/api/v1/participant-declarations", params: build_params(updated_params)
          end
        end

        context "when the participant has not been withdrawn" do
          before do
            induction_record.leaving!(ect_profile.schedule.milestones.first.start_date + 1)
            Induction::Enrol.call(participant_profile: ect_profile, induction_programme: programme, start_date: milestone_start_date)
          end

          it "is possible for the same lead provider to post a declaration" do
            updated_params = valid_params.merge({ declaration_date: (milestone_start_date + 2).rfc3339 })

            post "/api/v1/participant-declarations", params: build_params(updated_params)
          end
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
        expect(JSON.parse(response.body)["errors"]).to include({ title: "Bad or missing parameters", detail: I18n.t("activemodel.errors.models.record_declarations/base.attributes.participant_id.blank") }.stringify_keys)
      end

      it "ignores an unpermitted parameter" do
        post "/api/v1/participant-declarations", params: build_params(valid_params.merge(evidence_held: "test"))
        expect(response.status).to eq 200
        expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to be_nil
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
        expect(JSON.parse(response.body)["errors"]).to include({ title: "Bad or missing parameters", detail: I18n.t(:invalid_participant) }.stringify_keys)
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

      context "when it fails schema validation" do
        let(:params) { build_params(valid_params.merge(foo: "bar")) }

        it "logs info to rails logger" do
          allow(Rails).to receive(:logger).and_return(fake_logger)

          post "/api/v1/participant-declarations", params: params

          expect(response.status).to eql(200)
          expect(fake_logger).to have_received(:info).with("Failed schema validation for #{request.body.read}").ordered
          expect(fake_logger).to have_received(:info).with(instance_of(Array)).ordered
        end
      end

      context "when existing declaration" do
        context "has state awaiting_clawback" do
          let!(:existing_participant_declaration) do
            create(
              :participant_declaration,
              :awaiting_clawback,
              user: ect_profile.user,
              cpd_lead_provider:,
              participant_profile: ect_profile,
              course_identifier: valid_params[:course_identifier],
            )
          end

          it "returns 200" do
            expect(ect_profile.participant_declarations.awaiting_clawback.count).to eq(1)

            params = build_params(valid_params)
            expect {
              post "/api/v1/participant-declarations", params: params
              expect(response.status).to eq 200
            }.to change { ect_profile.participant_declarations.submitted.count }.from(0).to(1)

            expect(existing_participant_declaration.reload).to be_awaiting_clawback
          end
        end

        context "has state clawed_back" do
          let!(:existing_participant_declaration) do
            create(
              :participant_declaration,
              :clawed_back,
              user: ect_profile.user,
              cpd_lead_provider:,
              participant_profile: ect_profile,
              course_identifier: valid_params[:course_identifier],
            )
          end

          it "returns 200" do
            expect(ect_profile.participant_declarations.clawed_back.count).to eq(1)

            params = build_params(valid_params)
            expect {
              post "/api/v1/participant-declarations", params: params
              expect(response.status).to eq 200
            }.to change { ect_profile.participant_declarations.submitted.count }.from(0).to(1)

            expect(existing_participant_declaration.reload).to be_clawed_back
          end
        end

        context "has state non clawback state" do
          let!(:existing_participant_declaration) do
            create(
              :participant_declaration,
              :paid,
              user: ect_profile.user,
              cpd_lead_provider:,
              participant_profile: ect_profile,
              course_identifier: valid_params[:course_identifier],
            )
          end

          it "returns 422" do
            expect(ect_profile.participant_declarations.paid.count).to eq(1)

            params = build_params(valid_params)
            post "/api/v1/participant-declarations", params: params
            expect(response.status).to eq 422

            expect(ect_profile.participant_declarations.paid.count).to eq(1)
          end
        end
      end

      context "when participant has been retained", with_feature_flags: { multiple_cohorts: "active" } do
        let!(:cohort) { create(:cohort, :next) }
        let!(:started_declaration) { create(:participant_declaration, user: ect_profile.user, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile: ect_profile) }
        let(:milestone_start_date) { ect_profile.schedule.milestones.find_by(declaration_type:).start_date }
        let(:valid_params) do
          {
            participant_id: ect_profile.user.id,
            declaration_type:,
            declaration_date: milestone_start_date.rfc3339,
            course_identifier: "ecf-induction",
            evidence_held: "other",
          }
        end

        before do
          travel_to milestone_start_date + 6.months
        end

        context "with milestone in the same year as the cohort start year" do
          let(:declaration_type) { "retained-1" }
          it "creates a declaration record" do
            params = build_params(valid_params)
            expect { post "/api/v1/participant-declarations", params: }.to change(ParticipantDeclaration, :count).by(1).and change(ParticipantDeclarationAttempt, :count).by(1)
          end

          it "sets the correct declaration type on the declaration record" do
            params = build_params(valid_params)
            post "/api/v1/participant-declarations", params: params

            expect(response.status).to eq 200
            declaration = ParticipantDeclaration::ECF.find(JSON.parse(response.body).dig("data", "id"))
            expect(declaration.declaration_type).to eq(declaration_type)
          end
        end

        context "with milestone in the year after the cohort start year" do
          let!(:retained_1_declaration) { create(:participant_declaration, user: ect_profile.user, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile: ect_profile, declaration_type: "retained-1") }
          let!(:retained_2_declaration) { create(:participant_declaration, user: ect_profile.user, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile: ect_profile, declaration_type: "retained-2") }
          let(:declaration_type) { "retained-3" }

          it "creates a declaration record" do
            params = build_params(valid_params)
            expect { post "/api/v1/participant-declarations", params: }.to change(ParticipantDeclaration, :count).by(1).and change(ParticipantDeclarationAttempt, :count).by(1)
          end

          it "sets the correct declaration type on the declaration record" do
            params = build_params(valid_params)
            post "/api/v1/participant-declarations", params: params

            expect(response.status).to eq 200
            declaration = ParticipantDeclaration::ECF.find(JSON.parse(response.body).dig("data", "id"))
            expect(declaration.declaration_type).to eq(declaration_type)
          end
        end
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
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token) { "Bearer #{token}" }

    let!(:participant_declaration) do
      create(:participant_declaration,
             user: ect_profile.user,
             cpd_lead_provider:,
             participant_profile: ect_profile,
             course_identifier: "ecf-induction")
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

        it "loads list of declarations" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when there is a voided declaration" do
        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile, state: "voided")
        end

        before do
          participant_declaration.voided!
        end

        it "loads list of declarations" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when there is an eligible declaration" do
        before do
          participant_declaration.make_eligible!
        end

        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: ect_profile, state: "eligible")
        end

        before do
          default_headers[:Authorization] = bearer_token
          default_headers[:CONTENT_TYPE] = "application/json"
        end

        it "loads list of declarations" do
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
        let!(:second_ect_profile) { create(:ect_participant_profile, schedule: default_schedule) }
        let!(:second_participant_declaration) do
          create(:participant_declaration,
                 user: second_ect_profile.user,
                 cpd_lead_provider:,
                 course_identifier: "ecf-induction",
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

        it "returns 404 if participant declaration does not exist", exceptions_app: true do
          get "/api/v1/participant-declarations/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe "CSV Index API" do
    let(:parsed_response) { CSV.parse(response.body, headers: true) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token) { "Bearer #{token}" }

    let!(:participant_declaration_one) do
      create(:ect_participant_declaration,
             participant_profile: ect_profile,
             user: ect_profile.user,
             cpd_lead_provider:)
    end

    let!(:participant_declaration_two) do
      create(:ect_participant_declaration,
             participant_profile: ect_profile,
             user: ect_profile.user,
             cpd_lead_provider:)
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
        %w[id course_identifier declaration_date declaration_type participant_id state eligible_for_payment voided updated_at],
      )
    end

    it "returns the correct values" do
      participant_declaration_one_row = parsed_response.find { |row| row["id"] == participant_declaration_one.id }
      expect(participant_declaration_one_row).not_to be_nil
      expect(participant_declaration_one_row["course_identifier"]).to eql participant_declaration_one.course_identifier
      expect(participant_declaration_one_row["declaration_date"]).to eql participant_declaration_one.declaration_date.rfc3339
      expect(participant_declaration_one_row["declaration_type"]).to eql participant_declaration_one.declaration_type
      expect(participant_declaration_one_row["eligible_for_payment"]).to eql (participant_declaration_one.eligible? || participant_declaration_one.payable?).to_s
      expect(participant_declaration_one_row["voided"]).to eql participant_declaration_one.voided?.to_s
      expect(participant_declaration_one_row["state"]).to eql participant_declaration_one.state.to_s
      expect(participant_declaration_one_row["participant_id"]).to eql participant_declaration_one.participant_profile.user.id
      expect(participant_declaration_one_row["updated_at"]).to eql participant_declaration_one.updated_at.rfc3339
    end

    it "ignores pagination parameters" do
      get "/api/v1/participant-declarations.csv", params: { page: { per_page: 1, page: 1 } }
      expect(parsed_response.length).to eql 2
    end
  end

  describe "PUT /api/v1/participant-declarations/:id/void" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "when declaration is submitted" do
      let(:declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }

      it "can be voided" do
        expect {
          put "/api/v1/participant-declarations/#{declaration.id}/void"
        }.to change { declaration.reload.state }.from("submitted").to("voided")
      end

      it "returns a 200" do
        put "/api/v1/participant-declarations/#{declaration.id}/void"
        expect(response.status).to eql(200)
      end
    end

    context "when declaration is payable" do
      let(:declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }

      it "can be voided" do
        expect {
          put "/api/v1/participant-declarations/#{declaration.id}/void"
        }.to change { declaration.reload.state }.from("payable").to("voided")
      end

      it "returns a 200" do
        put "/api/v1/participant-declarations/#{declaration.id}/void"
        expect(response.status).to eql(200)
      end
    end
  end

private

  def expected_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted")
    {
      "data" =>
          [
            single_json_declaration(declaration:, profile:, course_identifier:, state:),
          ],
    }
  end

  def expected_single_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted")
    {
      "data" =>
          single_json_declaration(declaration:, profile:, course_identifier:, state:),
    }
  end

  def single_json_declaration(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted")
    {
      "id" => declaration.id,
      "type" => "participant-declaration",
      "attributes" => {
        "participant_id" => profile.user.id,
        "declaration_type" => "started",
        "declaration_date" => declaration.declaration_date.rfc3339,
        "course_identifier" => course_identifier,
        "state" => state,
        "eligible_for_payment" => state == "eligible",
        "voided" => state == "voided",
        "updated_at" => declaration.updated_at.rfc3339,
      },
    }
  end
end
