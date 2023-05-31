# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF schools", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  let(:cohort) { create(:cohort, start_year: 2022) }
  let(:another_cohort) { create(:cohort, start_year: 2021) }

  let!(:school) { create(:school, :eligible) }
  let(:another_school) { create(:school, :closed) }
  let!(:another_partnership) { create(:partnership, school: another_school, cohort: another_cohort) }

  describe "#index" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct JSON API content type header" do
        get "/api/v3/schools/ecf"
        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      context "without required cohort filter param" do
        before { get "/api/v3/schools/ecf" }

        it "returns a 400 status code" do
          expect(response.status).to eq(400)
        end

        it "returns an error message" do
          expect(parsed_response["errors"][0]["detail"]).to eq("The filter '#/cohort' must be included in your request")
        end
      end

      context "with required cohort filter param" do
        before { get "/api/v3/schools/ecf", params: { filter: { cohort: cohort.start_year } } }

        context "when there are other schools not in the same cohort" do
          it "returns only those schools in the filtered cohort" do
            expect(parsed_response["data"].size).to eql(1)
            expect(parsed_response["data"][0]["id"]).to eq(school.id)
          end
        end

        it "returns correct type" do
          expect(parsed_response["data"][0]).to have_type("school")
        end

        it "has correct attributes" do
          expect(parsed_response["data"][0]).to have_jsonapi_attributes(
            :name,
            :urn,
            :cohort,
            :in_partnership,
            :induction_programme_choice,
            :created_at,
            :updated_at,
          ).exactly
        end
      end

      describe "ordering" do
        let!(:another_partnership) do
          travel_to(Time.zone.now - 2.days) do
            create(:partnership, school: another_school, cohort:)
          end
        end

        context "when ordering by updated_at ascending" do
          let(:sort_param) { "updated_at" }

          before { get "/api/v3/schools/ecf", params: { sort: sort_param, filter: { cohort: cohort.display_name } } }

          it "returns an ordered list of schools" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "name")).to eql(another_school.name)
            expect(parsed_response.dig("data", 1, "attributes", "name")).to eql(school.name)
          end
        end

        context "when ordering by updated_at descending" do
          let(:sort_param) { "-updated_at" }

          before { get "/api/v3/schools/ecf", params: { sort: sort_param, filter: { cohort: cohort.display_name } } }

          it "returns an ordered list of schools" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "name")).to eql(school.name)
            expect(parsed_response.dig("data", 1, "attributes", "name")).to eql(another_school.name)
          end
        end

        context "when not including sort in the params" do
          before do
            another_school.update!(created_at: 10.days.ago)

            get "/api/v3/schools/ecf", params: { sort: "", filter: { cohort: cohort.display_name } }
          end

          it "returns all records ordered by created_at" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "name")).to eql(another_school.name)
            expect(parsed_response.dig("data", 1, "attributes", "name")).to eql(school.name)
          end
        end
      end

      context "when filtering by cohort" do
        it "returns all schools that match" do
          get "/api/v3/schools/ecf", params: { filter: { cohort: cohort.display_name } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "urn")).to eql(school.urn)
        end

        it "returns all schools that match" do
          get "/api/v3/schools/ecf", params: { filter: { cohort: another_cohort.display_name } }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response["data"].map { |school| school["attributes"]["urn"] }).to contain_exactly(another_school.urn, school.urn)
        end

        it "returns no schools if no matches" do
          get "/api/v3/schools/ecf", params: { filter: { cohort: "3100" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when filtering by school urn" do
        it "returns all schools that match" do
          get "/api/v3/schools/ecf", params: { filter: { urn: school.urn, cohort: cohort.display_name } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "urn")).to eql(school.urn)
        end

        it "returns all schools that match" do
          get "/api/v3/schools/ecf", params: { filter: { urn: another_school.urn, cohort: another_cohort.display_name } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "urn")).to eql(another_school.urn)
        end

        it "returns no schools if no matches" do
          get "/api/v3/schools/ecf", params: { filter: { urn: "ABC", cohort: cohort.display_name } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when filtering by updated_since" do
        let!(:school2) { create(:school, :eligible) }
        let!(:school3) { create(:school, :eligible) }
        let!(:school4) { create(:school, :eligible) }

        let!(:school_cohort3) { create(:school_cohort, school: school3, cohort:) }

        before do
          school.update!(updated_at: 3.days.ago)
          school2.update!(updated_at: 1.day.ago)

          school3.update!(updated_at: 10.days.ago)
          school_cohort3.update!(updated_at: 1.day.ago)

          school4.update!(updated_at: 6.days.ago)
        end

        it "returns statements updated after updated_since" do
          get "/api/v3/schools/ecf", params: { filter: { cohort: cohort.display_name, updated_since: 2.days.ago.iso8601 } }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "id")).to eql(school2.id)
          expect(parsed_response.dig("data", 1, "id")).to eql(school3.id)
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/schools/ecf"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/schools/ecf"

        expect(response.status).to eq(403)
      end
    end
  end

  describe "#show" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct JSON API content type header" do
        get "/api/v3/schools/ecf/#{school.id}"
        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      context "without required cohort filter param" do
        before { get "/api/v3/schools/ecf/#{school.id}" }

        it "returns a 400 status code" do
          expect(response.status).to eq(400)
        end

        it "returns an error message" do
          expect(parsed_response["errors"][0]["detail"]).to eq("The filter '#/cohort' must be included in your request")
        end
      end

      context "with required cohort filter param" do
        before { get "/api/v3/schools/ecf/#{school.id}", params: { filter: { cohort: cohort.start_year } } }

        context "when there are other schools not in the same cohort" do
          let!(:another_partnership) { create(:partnership, cohort: another_cohort) }

          it "returns only those schools in the filtered cohort" do
            expect(parsed_response["data"]["id"]).to eq(school.id)
          end
        end

        it "returns correct type" do
          expect(parsed_response["data"]).to have_type("school")
        end

        it "has correct attributes" do
          expect(parsed_response["data"]).to have_jsonapi_attributes(
            :name,
            :urn,
            :cohort,
            :in_partnership,
            :induction_programme_choice,
            :created_at,
            :updated_at,
          ).exactly
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/schools/ecf/#{school.id}"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/schools/ecf/#{school.id}"

        expect(response.status).to eq(403)
      end
    end
  end
end
