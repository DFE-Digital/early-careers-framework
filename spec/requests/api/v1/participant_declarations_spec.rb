# frozen_string_literal: true

require "rails_helper"

RSpec.describe "participant-declarations endpoint spec", type: :request do
  let(:cpd_lead_provider)    { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token)                { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token)         { "Bearer #{token}" }
  let(:fake_logger)          { double("logger", info: nil) }
  let(:traits)               { [] }
  let(:school_cohort)        { create(:school_cohort, :fip, :with_induction_programme, lead_provider: cpd_lead_provider.lead_provider) }
  let(:participant_profile)  { create(participant_type, *traits, school_cohort:) }
  let(:schedule)             { Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort) }
  let(:participant_type)     { :ect }
  let(:milestone_start_date) { schedule.milestones.find_by(declaration_type: "started").start_date }

  describe "POST /api/v1/participant-declarations" do
    let(:declaration_date)  { milestone_start_date }
    let(:declaration_type)  { "started" }
    let(:participant_id)    { participant_profile.user_id }
    let(:course_identifier) { "ecf-induction" }
    let(:params) do
      {
        data: {
          type: "participant-declaration",
          attributes: {
            participant_id:,
            declaration_type:,
            declaration_date: declaration_date.rfc3339,
            course_identifier:,
          },
        },
      }
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
        create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
      end

      describe "happy path" do
        let(:expected_declarations) { participant_profile.participant_declarations.where(declaration_type:, cpd_lead_provider:) }

        it "creates declaration record and declaration attempt and return id when successful" do
          post "/api/v1/participant-declarations", params: params.to_json

          expect(expected_declarations).to exist
          expect(expected_declarations.first.participant_declaration_attempts).to exist
          expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_json)
          expect(response).to be_successful
        end

        context "when the participant is eligible" do
          let(:traits) { [:eligible_for_funding] }

          it "create eligible declaration record when user is eligible" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(participant_profile.participant_declarations.eligible).to exist
          end
        end

        context "with schema validation" do
          it "logs passing schema validation" do
            allow(Rails).to receive(:logger).and_return(fake_logger)

            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).to be_successful
            expect(fake_logger).to have_received(:info).with("Passed schema validation").ordered
          end
        end
      end

      context "when posting for the new cohort" do
        let(:school)              { create(:school) }
        let(:next_cohort)         { Cohort.next || create(:cohort, :next) }
        let(:next_school_cohort)  { create(:school_cohort, :fip, :with_induction_programme, school:, cohort: next_cohort, lead_provider: cpd_lead_provider.lead_provider) }
        let(:participant_profile) { create(:ect, :eligible_for_funding, school_cohort: next_school_cohort, lead_provider: cpd_lead_provider.lead_provider) }
        let!(:next_schedule) do
          Finance::Schedule::ECF.default_for(cohort: next_cohort)
        end

        let(:milestone_start_date) { participant_profile.schedule.milestones.first.start_date }

        before do
          create(:ecf_statement, :output_fee, cohort: next_cohort, deadline_date: participant_profile.schedule.milestones.first.milestone_date, cpd_lead_provider:)
        end

        it "create declaration record and declaration attempt and return id when successful", :aggregate_failures do
          travel_to declaration_date do
            post "/api/v1/participant-declarations", params: params.to_json
          end

          declaration = ParticipantDeclaration::ECF.find(parsed_response.dig("data", "id"))

          expect(response).to be_successful
          expect(declaration.participant_profile.schedule).to eq(next_schedule)
          expect(declaration.statements.first.cohort).to eq(next_cohort)
        end
      end

      it "create declaration record and declaration attempt and return id when successful" do
        expect {
          post "/api/v1/participant-declarations", params: params.to_json
        }.to change(ParticipantDeclaration, :count).by(1)
               .and change(ParticipantDeclarationAttempt, :count).by(1)

        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_json)
        expect(response).to be_successful
        expect(parsed_response["data"]["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      context "when the participant is eligible" do
        let(:traits) { [:eligible_for_funding] }

        it "create eligible declaration record when user is eligible" do
          post "/api/v1/participant-declarations", params: params.to_json

          expect(ParticipantDeclaration.order(:created_at).last).to be_eligible
        end
      end

      it "does not create duplicate declarations with the same declaration date" do
        post "/api/v1/participant-declarations", params: params.to_json

        expect {
          expect {
            post "/api/v1/participant-declarations", params: params.to_json
          }.not_to change(ParticipantDeclaration, :count)
        }.to change(ParticipantDeclarationAttempt, :count).by(1)

        expect(response).not_to be_successful
        expect(parsed_response["errors"]).to eq(["title" => "base", "detail" => "A declaration has already been submitted that will be, or has been, paid for this event"])
      end

      context "with different declaration date" do
        before do
          post "/api/v1/participant-declarations", params: params.to_json
          params[:data][:attributes][:declaration_date] = (milestone_start_date + 1.second).rfc3339
        end

        it "does not create duplicate declarations" do
          expect { post "/api/v1/participant-declarations", params: params.to_json }
            .not_to change(ParticipantDeclaration, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response)
            .to eq({ "errors" => [
              { "title" => "base", "detail" => "A declaration has already been submitted that will be, or has been, paid for this event" },
            ] })
        end
      end

      context "when lead provider has no access to the user" do
        let(:another_lead_provider_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: create(:cpd_lead_provider, :with_lead_provider).lead_provider) }
        let(:participant_profile)                 { create(participant_type, *traits, school_cohort: another_lead_provider_school_cohort) }

        it "create declaration attempt" do
          expect { post "/api/v1/participant-declarations", params: params.to_json }
            .to change(ParticipantDeclarationAttempt, :count).by(1)
        end

        it "does not create declaration" do
          expect { post "/api/v1/participant-declarations", params: params.to_json }
            .not_to change(ParticipantDeclaration, :count)
          expect(response.status).to eq 422
        end
      end

      context "when participant is withdrawn" do
        before do
          participant_profile.participant_profile_states.create({ state: "withdrawn", created_at: milestone_start_date - 1.second })
        end

        it "returns 200" do
          post "/api/v1/participant-declarations", params: params.to_json

          expect(response).to be_successful
        end
      end

      context "when participant is deferred" do
        before do
          participant_profile.participant_profile_states.create({ state: "deferred", created_at: milestone_start_date - 1.second })
        end

        it "returns 200" do
          post "/api/v1/participant-declarations", params: params.to_json
          expect(response).to be_successful
        end
      end

      context "when the participant transfers to a new school with a different lead provider" do
        let(:new_cpd_lead_provider)    { create(:cpd_lead_provider, :with_lead_provider) }
        let(:new_school)               { create(:school, name: "Transferred-to School") }
        let(:new_school_cohort)        { create(:school_cohort, :fip, :with_induction_programme, lead_provider: new_cpd_lead_provider.lead_provider) }
        let(:transfer_lp_token)        { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: new_cpd_lead_provider) }
        let(:transfer_lp_bearer_token) { "Bearer #{transfer_lp_token}" }
        let(:url)                      { "/api/v1/participants/ecf/#{participant_profile.user_id}/withdraw" }
        let(:participant_profile_date) { Time.zone.now }

        before do
          travel_to(participant_profile_date) do
            participant_profile
          end

          Induction::TransferToSchoolsProgramme.call(
            induction_programme: new_school_cohort.default_induction_programme,
            start_date: milestone_start_date + 1,
            participant_profile:,
          )
        end

        context "when the participant has been withdrawn" do
          let(:withdrawal_date) { (milestone_start_date + 5.days).in_time_zone }
          let(:participant_profile_date) { withdrawal_date - 1.second }

          before do
            travel_to(withdrawal_date) do
              put url, params: { data: { type: :participant, attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } }.to_json
            end
          end

          context "when the new lead provider posts a declaration" do
            before do
              default_headers[:Authorization] = transfer_lp_bearer_token
              post "/api/v1/participant-declarations", params: params.to_json
            end

            it "is possible for new lead provider to post a declaration" do
              expect(response).to be_successful
            end

            context "when the old provider makes a query" do
              before { default_headers[:Authorization] = bearer_token }

              it "is not possible for previous lead provider to view future declarations" do
                expect { get "/api/v1/participant-declarations/#{participant_profile.participant_declarations.first.id}" }
                  .to raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end

          context "when the old lead provider post a declaration" do
            let!(:old_provider_declaration) do
              post "/api/v1/participant-declarations", params: params.to_json
              parsed_response
            end

            it "is possible for previous lead provider to submit backdated declarations" do
              expect(response).to be_successful
            end

            context "when the declaration date is after the participant's withdrawal" do
              let(:declaration_date) { withdrawal_date + 1 }

              it "is not possible for previous lead provider to submit a declaration after withdrawal date", :aggregate_failures do
                expect(response).not_to be_successful
                expect(response).to have_http_status(:unprocessable_entity)

                expect(parsed_response["errors"])
                  .to eq([{ "title" => "participant_id", "detail" => "This participant withdrew from this course on #{withdrawal_date.rfc3339}. Enter a '#/declaration_date' that's on or before the withdrawal date." }])
              end
            end

            context "when the new lead provider makes a request" do
              before do
                default_headers[:Authorization] = transfer_lp_bearer_token
              end

              it "is not possible for new lead provider to post same declaration_type as previous lead provider" do
                post "/api/v1/participant-declarations", params: params.to_json

                expect(response).not_to be_successful
                expect(response).to have_http_status(:unprocessable_entity)
                expect(parsed_response["errors"])
                  .to eq(
                    [
                      { "title" => "base", "detail" => "A declaration has already been submitted that will be, or has been, paid for this event" },
                    ],
                  )
              end
            end
          end
        end

        context "when the participant has not been withdrawn" do
          context "When the new lead provider submits a declaration" do
            let(:declaration_date) { (milestone_start_date + 2) }

            it "is possible for new lead provider to post a declaration" do
              default_headers[:Authorization] = transfer_lp_bearer_token

              post "/api/v1/participant-declarations", params: params.to_json

              expect(response).to be_successful
            end
          end

          context "when the old provider submits a declaration" do
            it "is possible for previous lead provider to submit backdated declarations" do
              post "/api/v1/participant-declarations", params: params.to_json

              expect(response).to be_successful
            end
          end

          context "when the participant has been transfered to a school with different lead provider" do
            it "is not possible for the previous lead provider to view future declarations" do
              default_headers[:Authorization] = transfer_lp_bearer_token

              post "/api/v1/participant-declarations", params: params.to_json

              expect(response).to be_successful

              default_headers[:Authorization] = bearer_token
              expect { get "/api/v1/participant-declarations/#{participant_profile.participant_declarations.first.id}" }
                .to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end
      end

      context "when the participant transfers to a new school with the same lead provider" do
        let(:new_school)        { create(:school, name: "Transferred-to School") }
        let(:new_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: cpd_lead_provider.lead_provider) }
        let(:url)               { "/api/v1/participants/ecf/#{participant_profile.user.id}/withdraw" }
        let(:withdrawal_params) { { data: { type: :particpant, attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }

        context "when the participant has been withdrawn" do
          before do
            Induction::TransferToSchoolsProgramme.call(
              induction_programme: new_school_cohort.default_induction_programme,
              start_date: milestone_start_date + 1,
              participant_profile:,
            )

            put url, params: withdrawal_params.to_json
          end

          it "is possible for the same lead provider to post a declaration" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).to be_successful
          end
        end

        context "when the participant has not been withdrawn" do
          let(:declaration_date) { (milestone_start_date + 2) }
          it "is possible for the same lead provider to post a declaration" do
            post "/api/v1/participant-declarations", params: params.to_json
            expect(response).to be_successful
          end
        end
      end

      context "when parameters are not correct" do
        context "when a required parameter does not exist" do
          let(:participant_id) { SecureRandom.uuid }

          it "returns 422 when trying to create with no id", :aggregate_failures do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).not_to be_successful
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when a required parameter is missing" do
          let(:participant_id) {}

          it "returns 422" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).not_to be_successful
            expect(response).to have_http_status(:unprocessable_entity)
            expect(parsed_response["errors"])
              .to include({ "title" => "participant_id", "detail" => "Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again." })
          end
        end
        context "with unpermitted parameter" do
          before { params[:data][:attributes][:evidence_held] = "test" }

          it "creates the declaration" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).to be_successful
            expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to eq("test")
          end
        end

        context "whe the course identifier is incorrect" do
          let(:course_identifier) { "typoed-course-name" }
          it "returns 422 when supplied an incorrect course type" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).not_to be_successful
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when a participant type doesn't match the course type" do
          let(:course_identifier) { "ecf-mentor" }
          it "returns 422 " do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).not_to be_successful
            expect(response).to have_http_status(:unprocessable_entity)
            expect(parsed_response["errors"]).to include({ "title" => "course_identifier", "detail" => "The entered '#/course_identifier' is not recognised for the given participant. Check details and try again." })
          end
        end

        it "returns 422 when there are multiple errors" do
          post "/api/v1/participant-declarations", params: { data: { type: :participant, attributes: {} } }.to_json

          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response["errors"])
            .to eq(
              [
                { "title" => "participant_id", "detail" => "Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again." },
                { "title" => "declaration_date", "detail" => "Enter a '#/declaration_date'." },
                { "title" => "declaration_type", "detail" => "Enter a '#/declaration_type'." },
              ],
            )
        end

        it "returns 400 when the data block is incorrect" do
          post "/api/v1/participant-declarations", params: {}.to_json

          expect(response).not_to be_successful
          expect(response).to have_http_status(:bad_request)
          expect(parsed_response["errors"]).to eq([{ "title" => "Bad request", "detail" => I18n.t(:invalid_data_structure) }])
        end

        context "when it fails schema validation" do
          before { params[:data][:attributes][:foo] = "bar" }

          it "logs info to rails logger" do
            allow(Rails).to receive(:logger).and_return(fake_logger)

            post "/api/v1/participant-declarations", params: params.to_json

            expect(response).to be_successful
            expect(fake_logger).to have_received(:info).with("Failed schema validation for #{request.body.read}").ordered
            expect(fake_logger).to have_received(:info).with(instance_of(Array)).ordered
          end
        end
      end

      context "when existing declaration" do
        let(:traits) { [:eligible_for_funding] }
        context "has state awaiting_clawback" do
          let!(:existing_participant_declaration) do
            travel_to create(:ecf_statement, cpd_lead_provider:).deadline_date do
              create(:ect_participant_declaration, :eligible, :awaiting_clawback, cpd_lead_provider:, participant_profile:)
            end
          end

          it "returns 200" do
            expect(participant_profile.participant_declarations.awaiting_clawback.count).to eq(1)

            expect {
              post "/api/v1/participant-declarations", params: params.to_json
              expect(response.status).to eq 200
            }.to change { participant_profile.reload.participant_declarations.eligible.count }.from(0).to(1)

            expect(existing_participant_declaration.reload).to be_awaiting_clawback
          end
        end

        context "has state clawed_back" do
          let!(:existing_participant_declaration) do
            travel_to create(:ecf_statement, cpd_lead_provider:).deadline_date do
              create(:ect_participant_declaration, :eligible, :clawed_back, cpd_lead_provider:, participant_profile:)
            end
          end

          it "returns 200" do
            expect(participant_profile.participant_declarations.clawed_back.count).to eq(1)

            expect {
              post "/api/v1/participant-declarations", params: params.to_json
              expect(response.status).to eq 200
            }.to change { participant_profile.participant_declarations.eligible.count }.from(0).to(1)

            expect(existing_participant_declaration.reload).to be_clawed_back
          end
        end

        context "has state non clawback state" do
          let!(:existing_participant_declaration) do
            travel_to create(:ecf_statement, cpd_lead_provider:).deadline_date do
              create(:ect_participant_declaration, :paid, cpd_lead_provider:, participant_profile:)
            end
          end

          it "returns return the exisitng declaration" do
            expect(participant_profile.participant_declarations.paid.count).to eq(1)

            expect {
              post "/api/v1/participant-declarations", params: params.to_json
              expect(response).not_to be_successful
            }.not_to change { participant_profile.participant_declarations.paid.count }
          end
        end
      end

      context "when participant has been retained" do
        let!(:cohort) { Cohort.next || create(:cohort, :next) }
        let!(:started_declaration) { create(:ect_participant_declaration, cpd_lead_provider:, participant_profile:) }
        let(:milestone_start_date) { participant_profile.schedule.milestones.find_by(declaration_type:).start_date }
        let(:params) do
          {
            data: {
              type: "participant-declaration",
              attributes: {
                participant_id: participant_profile.participant_identity.user_id,
                declaration_type:,
                declaration_date: milestone_start_date.rfc3339,
                course_identifier: "ecf-induction",
                evidence_held: "other",
              },
            },
          }
        end

        before do
          travel_to milestone_start_date + 6.months
        end

        context "with milestone in the same year as the cohort start year" do
          let(:declaration_type) { "retained-1" }
          it "creates a declaration record" do
            expect {
              post "/api/v1/participant-declarations", params: params.to_json
            }.to change(ParticipantDeclaration, :count).by(1)
             .and change(ParticipantDeclarationAttempt, :count).by(1)
          end

          it "sets the correct declaration type on the declaration record" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response.status).to eq 200
            declaration = ParticipantDeclaration::ECF.find(JSON.parse(response.body).dig("data", "id"))
            expect(declaration.declaration_type).to eq(declaration_type)
          end
        end

        context "with milestone in the year after the cohort start year" do
          let!(:retained_1_declaration) { create(:ect_participant_declaration, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile:, declaration_type: "retained-1") }
          let!(:retained_2_declaration) { create(:ect_participant_declaration, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile:, declaration_type: "retained-2") }
          let(:declaration_type) { "retained-3" }

          it "creates a declaration record" do
            expect {
              post "/api/v1/participant-declarations", params: params.to_json
            }.to change(ParticipantDeclaration, :count).by(1)
             .and change(ParticipantDeclarationAttempt, :count).by(1)
          end

          it "sets the correct declaration type on the declaration record" do
            post "/api/v1/participant-declarations", params: params.to_json

            expect(response.status).to eq 200
            declaration = ParticipantDeclaration::ECF.find(JSON.parse(response.body).dig("data", "id"))
            expect(declaration.declaration_type).to eq(declaration_type)
          end
        end
      end

      context "when NPQ participant has completed declaration" do
        let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
        let(:declaration_date)      { participant_profile.schedule.milestones.find_by(declaration_type:).start_date + 1.day }
        let(:npq_course) { create(:npq_leadership_course) }
        let(:participant_profile) do
          create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:)
        end
        let(:course_identifier) { npq_course.identifier }
        let(:declaration_type)  { "completed" }
        let(:has_passed) { nil }
        let!(:contract) { create(:npq_contract, npq_course:, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
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
          let(:has_passed)  { true }

          it "creates passed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v1/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(true)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end

        context "has_passed is false" do
          let(:has_passed)  { false }

          it "creates failed participant outcome" do
            expect(ParticipantOutcome::NPQ.count).to eql(0)
            post "/api/v1/participant-declarations", params: params.to_json
            expect(parsed_response["data"]["attributes"]["has_passed"]).to eq(false)
            expect(ParticipantOutcome::NPQ.count).to eql(1)
          end
        end

        context "when CreateParticipantOutcome service class is invalid" do
          let(:has_passed) { true }

          before do
            allow_any_instance_of(NPQ::CreateParticipantOutcome).to receive(:valid?).and_return(false)
          end

          it "returns 422" do
            post "/api/v1/participant-declarations", params: params.to_json
            expect(response.status).to eq 422
            expect(response.body).to eq({ errors: [{ title: "Invalid action", detail: I18n.t(:cannot_create_completed_declaration) }] }.to_json)
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"

        post "/api/v1/participant-declarations", params: params.to_json

        expect(response).to have_http_status(:unauthorized)
        expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq(params.to_json)
      end
    end
  end

  describe "JSON Index Api" do
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token) { "Bearer #{token}" }

    let!(:participant_declaration) do
      create(:participant_declaration,
             user: participant_profile.user,
             cpd_lead_provider:,
             participant_profile:,
             course_identifier: "ecf-induction")
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      context "when there is a non eligible declaration" do
        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: participant_profile)
        end

        it "loads list of declarations" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      describe "NPQ Registration Proxy JSON API" do
        let(:expected_response) do
          resp = expected_json_response(declaration: participant_declaration, profile: participant_profile)
          resp["data"] << npq_response_body[:data][0].deep_stringify_keys
          resp
        end

        let(:npq_response_body) do
          {
            data:             [
              {
                id: "9c0c67ca-5efd-4106-91ef-0c94412b1748",
                type: "participant-declaration",
                attributes: {
                  participant_id: "dc5bc897-1dec-495e-bdfa-c4cd058b3fba",
                  declaration_type: "started",
                  course_identifier: "npq-headship",
                  eligible_for_payment: false,
                  declaration_date: "2022-10-21T00:00:00Z",
                  updated_at: "2023-11-13T15:36:04Z",
                  voided: false,
                  state: "submitted",
                  has_passed: nil,
                },
              },
            ],
          }
        end

        before do
          stub_request(:get, "http://npq_registration.example.com:443/api/v1/participant-declarations")
            .with(
              headers: {
                "Accept"=>"*/*",
                "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                "Authorization" => bearer_token,
                "Host"=>"npq_registration.example.com",
                "User-Agent"=>"Ruby",
              },
            )
              .to_return(status: 200, body: npq_response_body.to_json, headers: {})
        end

        it "returns both ECF and NPQ declarations" do
          get "/api/v1/participant-declarations"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end
      end

      context "when there is a voided declaration" do
        let(:expected_response) do
          expected_json_response(declaration: participant_declaration, profile: participant_profile, state: "voided")
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
          expected_json_response(declaration: participant_declaration, profile: participant_profile, state: "eligible")
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
        let(:second_participant_profile) { create(:ect, school_cohort:) }
        let!(:second_participant_declaration) { create(:ect_participant_declaration, participant_profile: second_participant_profile, cpd_lead_provider:) }

        let(:expected_response) do
          expected_json_response(declaration: second_participant_declaration, profile: second_participant_profile)
        end

        it "loads only declarations for the chosen participant id" do
          get "/api/v1/participant-declarations", params: { filter: { participant_id: second_participant_profile.user.id } }

          expect(response).to be_successful
          expect(parsed_response).to eq(expected_response)
        end

        it "does not load declaration for a non-existent participant id" do
          get "/api/v1/participant-declarations", params: { filter: { participant_id: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" } }
          expect(response).to be_successful

          expect(parsed_response).to eq({ "data" => [] })
        end
      end

      context "when querying a single participant declaration" do
        let(:expected_response) do
          expected_single_json_response(declaration: participant_declaration, profile: participant_profile)
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

      context "when querying a single old participant declaration owned by another provider" do
        let(:old_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:old_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: old_cpd_lead_provider.lead_provider) }
        let(:participant_profile) { create(participant_type, *traits, school_cohort: old_school_cohort) }

        let!(:participant_declaration) { nil }

        let(:old_participant_declaration) do
          create(
            :participant_declaration,
            user: participant_profile.user,
            cpd_lead_provider: old_cpd_lead_provider,
            participant_profile:,
            course_identifier: "ecf-induction",
          )
        end

        let(:new_participant_declaration) do
          create(
            :participant_declaration,
            user: participant_profile.user,
            cpd_lead_provider:,
            participant_profile:,
            course_identifier: "ecf-induction",
            declaration_type: "retained-1",
          )
        end

        before do
          old_participant_declaration

          Induction::TransferToSchoolsProgramme.call(
            participant_profile:,
            induction_programme: school_cohort.default_induction_programme,
          )
          participant_profile.reload

          new_participant_declaration
        end

        it "loads old provider declaration" do
          get "/api/v1/participant-declarations/#{old_participant_declaration.id}"
          expect(response.status).to eq 200

          expected_response = expected_single_json_response(declaration: old_participant_declaration, profile: participant_profile)
          expect(JSON.parse(response.body)).to eq(expected_response)
        end

        it "loads new provider declaration" do
          get "/api/v1/participant-declarations/#{new_participant_declaration.id}"
          expect(response.status).to eq 200

          expected_response = expected_single_json_response(declaration: new_participant_declaration, profile: participant_profile, declaration_type: "retained-1")
          expect(JSON.parse(response.body)).to eq(expected_response)
        end
      end
    end
  end

  describe "CSV Index API" do
    let(:parsed_response) { CSV.parse(response.body, headers: true) }
    let(:token)           { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token)    { "Bearer #{token}" }

    let!(:participant_declaration_one) do
      create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
    end

    before do
      create(:ect_participant_declaration, participant_profile: create(:ect, school_cohort:, lead_provider: cpd_lead_provider.lead_provider), cpd_lead_provider:)
      default_headers[:Authorization] = bearer_token
      get "/api/v1/participant-declarations.csv"
    end

    it "returns the correct CSV content type header" do
      expect(response.headers["Content-Type"]).to eql("text/csv")
    end

    it "returns all declarations" do
      expect(parsed_response.length).to eq(2)
    end

    it "returns the correct headers" do
      expect(parsed_response.headers).to match_array(
        %w[id course_identifier declaration_date declaration_type participant_id state eligible_for_payment voided updated_at has_passed],
      )
    end

    it "returns the correct values" do
      participant_declaration_one_row = parsed_response.find { |row| row["id"] == participant_declaration_one.id }
      expect(participant_declaration_one_row).not_to be_nil
      expect(participant_declaration_one_row["course_identifier"]).to    eq(participant_declaration_one.course_identifier)
      expect(participant_declaration_one_row["declaration_date"]).to     eq(participant_declaration_one.declaration_date.rfc3339)
      expect(participant_declaration_one_row["declaration_type"]).to     eq(participant_declaration_one.declaration_type)
      expect(participant_declaration_one_row["eligible_for_payment"]).to eq(participant_declaration_one.eligible?.to_s)
      expect(participant_declaration_one_row["voided"]).to               eq(participant_declaration_one.voided?.to_s)
      expect(participant_declaration_one_row["state"]).to                eq(participant_declaration_one.state.to_s)
      expect(participant_declaration_one_row["participant_id"]).to       eq(participant_declaration_one.participant_profile.user.id)
      expect(participant_declaration_one_row["updated_at"]).to           eq(participant_declaration_one.updated_at.rfc3339)
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

    context "when old participant declaration owned by another provider" do
      let(:old_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:old_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: old_cpd_lead_provider.lead_provider) }
      let(:participant_profile) { create(participant_type, *traits, school_cohort: old_school_cohort) }

      let(:old_participant_declaration) do
        create(
          :participant_declaration,
          user: participant_profile.user,
          cpd_lead_provider: old_cpd_lead_provider,
          participant_profile:,
          course_identifier: "ecf-induction",
        )
      end

      let(:new_participant_declaration) do
        create(
          :participant_declaration,
          user: participant_profile.user,
          cpd_lead_provider:,
          participant_profile:,
          course_identifier: "ecf-induction",
          declaration_type: "retained-1",
        )
      end

      before do
        old_participant_declaration

        Induction::TransferToSchoolsProgramme.call(
          participant_profile:,
          induction_programme: school_cohort.default_induction_programme,
        )
        participant_profile.reload

        new_participant_declaration
      end

      it "should return not found for old_participant_declaration" do
        expect {
          put "/api/v1/participant-declarations/#{old_participant_declaration.id}/void"
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "should void new_participant_declaration" do
        put "/api/v1/participant-declarations/#{new_participant_declaration.id}/void"
        expect(response.status).to eql(200)
      end
    end
  end

private

  def parsed_response
    JSON.parse(response.body)
  end

  def expected_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil, declaration_type: "started")
    {
      "data" =>
      [
        single_json_declaration(declaration:, profile:, course_identifier:, state:, has_passed:, declaration_type:),
      ],
    }
  end

  def expected_single_json_response(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil, declaration_type: "started")
    {
      "data" =>
      single_json_declaration(declaration:, profile:, course_identifier:, state:, has_passed:, declaration_type:),
    }
  end

  def single_json_declaration(declaration:, profile:, course_identifier: "ecf-induction", state: "submitted", has_passed: nil, declaration_type: "started")
    {
      "id" => declaration.id,
      "type" => "participant-declaration",
      "attributes" => {
        "participant_id" => profile.user.id,
        "declaration_type" => declaration_type,
        "declaration_date" => declaration.declaration_date.rfc3339,
        "course_identifier" => course_identifier,
        "state" => state,
        "eligible_for_payment" => state == "eligible",
        "voided" => state == "voided",
        "updated_at" => declaration.updated_at.rfc3339,
        "has_passed" => has_passed,
      },
    }
  end
end
