# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Participants API", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { create(:cohort, :current) }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:, private_api_access: true) }
  let(:bearer_token) { "Bearer #{token}" }

  before :each do
    default_headers[:Authorization] = bearer_token
  end

  let(:partnership) { create(:partnership, lead_provider:) }
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let(:induction_record) { create(:induction_record, induction_programme:, participant_profile: profile, mentor_profile:) }

  let(:profile) { create(:ect_participant_profile, mentor_profile:) }
  let(:user) { profile.user }
  let(:teacher_profile) { profile.teacher_profile }
  let(:identity) { profile.participant_identity }

  let(:mentor) { mentor_participant_profile.user }
  let(:mentor_profile) { create(:mentor_participant_profile) }

  before do
    induction_record
  end

  describe "GET /api/v1/participants/ecf" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }

        it "returns correct jsonapi content type header" do
          get "/api/v1/participants/ecf"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all users" do
          get "/api/v1/participants/ecf"

          expect(parsed_response["data"].size).to eql(1)
        end

        it "returns correct data" do
          get "/api/v1/participants/ecf"

          expect(parsed_response["data"][0]["id"]).to eql(user.id)
          expect(parsed_response["data"][0]["type"]).to eql("participant")

          expect(parsed_response["data"][0]["attributes"]["email"]).to eql(identity.email)
          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)
          expect(parsed_response["data"][0]["attributes"]["mentor_id"]).to eql(mentor_profile.user_id)
          expect(parsed_response["data"][0]["attributes"]["school_urn"]).to eql(induction_record.school_cohort.school.urn)
          expect(parsed_response["data"][0]["attributes"]["participant_type"]).to eql(profile.participant_type.to_s)
          expect(parsed_response["data"][0]["attributes"]["cohort"]).to eql(profile.cohort.start_year.to_s)
          expect(parsed_response["data"][0]["attributes"]["status"]).to eql(profile.status)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(profile.teacher_profile.trn)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number_validated"]).to be_falsey
          expect(parsed_response["data"][0]["attributes"]["eligible_for_funding"]).to be_nil
          expect(parsed_response["data"][0]["attributes"]["pupil_premium_uplift"]).to eql(profile.pupil_premium_uplift)
          expect(parsed_response["data"][0]["attributes"]["sparsity_uplift"]).to eql(profile.sparsity_uplift)
          expect(parsed_response["data"][0]["attributes"]["training_status"]).to eql(profile.training_status)
          expect(parsed_response["data"][0]["attributes"]["schedule_identifier"]).to eql(induction_record.schedule.schedule_identifier)
          expect(parsed_response["data"][0]["attributes"]["updated_at"]).to match(/^[1-9]\d{3}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
          expect(Time.zone.parse(parsed_response["data"][0]["attributes"]["updated_at"])).to be_within(10.seconds).of(user.updated_at)
        end

        context "when there is no mentor" do
          let(:mentor_profile) { nil }

          it "returns correct data" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"][0]["attributes"]["mentor_id"]).to be_nil
          end
        end

        context "NQT+1" do
          let(:cohort_2020) { create(:cohort, start_year: 2020) }

          before do
            induction_record.schedule.update!(cohort: cohort_2020)
          end

          it "does not include them" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"].size).to be_zero
          end
        end

        context "one profile with 2 induction records" do
          let(:profile) do
            create(
              :ect_participant_profile,
              mentor_profile:,
              training_status: "deferred", # something different as should use InductionRecord#training_status
            )
          end

          let(:induction_record) do
            create(
              :induction_record,
              induction_programme:,
              participant_profile: profile,
              training_status: "withdrawn",
            )
          end

          let!(:induction_record2) do
            create(
              :induction_record,
              induction_programme:,
              participant_profile: profile,
              start_date: 1.week.ago,
              training_status: "active",
            )
          end

          it "returns only the most recent induction record" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"].size).to eql(1)
            expect(parsed_response["data"][0]["attributes"]["training_status"]).to eql("active")
          end
        end

        xcontext "multiple profiles", "Fix in later PR: the new query does not account yet for multiple profiles although this should not happen" do
          let!(:induction_record2) { create(:induction_record, induction_programme:, participant_profile: profile2) }
          let(:profile2) { create(:ect_participant_profile, teacher_profile:) }

          it "returns one" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"].size).to eql(1)
          end
        end

        context "moving provider" do
          let(:induction_record) do
            create(
              :induction_record,
              induction_programme:,
              participant_profile: profile,
              training_status: "withdrawn",
            )
          end

          let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }
          let(:lead_provider2) { cpd_lead_provider2.lead_provider }
          let(:partnership2) { create(:partnership, lead_provider: lead_provider2) }
          let(:induction_programme2) { create(:induction_programme, partnership: partnership2) }

          let!(:induction_record2) do
            create(
              :induction_record,
              induction_programme: induction_programme2,
              participant_profile: profile,
              start_date: 1.week.ago,
              training_status: "active",
            )
          end
        end

        context "moving school but same provider" do
          let(:induction_record) do
            create(
              :induction_record,
              induction_programme:,
              participant_profile: profile,
              training_status: "withdrawn",
              start_date: 1.year.ago,
            )
          end

          let(:partnership2) { create(:partnership, lead_provider:) }
          let(:induction_programme2) { create(:induction_programme, partnership: partnership2) }

          let!(:induction_record2) do
            create(
              :induction_record,
              induction_programme: induction_programme2,
              participant_profile: profile,
              start_date: 1.week.ago,
              training_status: "active",
            )
          end

          it "returns data from new induction record" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"][0]["attributes"]["school_urn"]).to eql(induction_record2.induction_programme.school_cohort.school.urn)
          end
        end

        context "partnership has been challenged" do
          let(:partnership) do
            create(
              :partnership,
              lead_provider:,
              challenged_at: 10.days.ago,
              challenge_reason: Partnership.challenge_reasons[:not_confirmed],
            )
          end

          it "does not return the participant" do
            get "/api/v1/participants/ecf"

            expect(parsed_response["data"].size).to be_zero
          end
        end
      end
    end
  end
end
