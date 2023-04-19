# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Participant Declarations", :with_default_schedules, type: :request do
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

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider1) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  describe "#index", with_feature_flags: { api_v3: "active" } do
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
end
