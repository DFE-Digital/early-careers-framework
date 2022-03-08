# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:token) { EngageAndLearnApiToken.create_with_random_token! }
  let(:bearer_token) { "Bearer #{token}" }

  describe "#index" do
    before :each do
      # Heads up, for some reason the stored CIP IDs don't match
      cip = create(:core_induction_programme, name: "Teach First")
      school = create(:school)
      school_cohort = create(:school_cohort, school: school)
      mentor_profile = create(:mentor_participant_profile, school_cohort: school_cohort, core_induction_programme: cip)
      create(:npq_participant_profile, school: school)
      create(:npq_participant_profile, school: school, teacher_profile: mentor_profile.teacher_profile)
      create_list(:ect_participant_profile, 2, school_cohort: school_cohort, core_induction_programme: cip)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v2/users"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns all users" do
        get "/api/v2/users"
        expect(parsed_response["data"].size).to eql(User.count)
      end

      it "returns correct type" do
        get "/api/v2/users"
        expect(parsed_response["data"][0]).to have_type("user")
      end

      it "returns IDs" do
        get "/api/v2/users"
        expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v2/users"
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name).exactly
      end

      it "returns the right number of users per page" do
        get "/api/v2/users", params: { page: { per_page: 3, page: 1 } }
        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns different users for first page" do
        get "/api/v2/users", params: { page: { per_page: 3, page: 1 } }
        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns different users for second page" do
        get "/api/v2/users", params: { page: { per_page: 3, page: 2 } }
        expect(parsed_response["data"].size).to eql(1)
      end

      it "returns users changed since a particular time, if given a changed_since parameter" do
        User.order(:created_at).first.update!(updated_at: 2.days.ago)
        get "/api/v2/users", params: { filter: { updated_since: 1.day.ago.iso8601 } }
        expect(parsed_response["data"].size).to eql(3)
      end

      context "when filtering by email" do
        it "returns users that match" do
          email = User.is_ecf_participant.sample.email
          get "/api/v2/users", params: { filter: { email: email } }
          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "email")).to eql(email)
        end

        it "returns no users if no matches" do
          email = "dontexist@example.com"
          get "/api/v2/users", params: { filter: { email: email } }
          expect(parsed_response["data"].size).to eql(0)
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v2/users"
        expect(response.status).to eq 401
      end
    end

    context "when using a lead provider token" do
      let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: create(:lead_provider)) }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v2/users"
        expect(response.status).to eq 403
      end
    end
  end

  describe "#create" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers["Content-Type"] = "application/vnd.api+json"
      end

      let(:json) do
        {
          data: {
            type: "user",
            attributes: {
              full_name: "John Doe",
              email: "john.doe@example.com",
            },
          },
        }.to_json
      end

      it "returns a 201" do
        post "/api/v2/users.json", params: json
        expect(response).to be_created
      end

      it "returns correct jsonapi content type header" do
        post "/api/v2/users.json", params: json
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "creates a user record" do
        expect {
          post "/api/v2/users", params: json
        }.to change(User, :count).by(1)

        user = User.order(:created_at).last

        expect(user.full_name).to eql("John Doe")
        expect(user.email).to eql("john.doe@example.com")
      end

      it "returns the created user resource" do
        post "/api/v2/users.json", params: json

        user = User.order(:created_at).last

        expect(parsed_response["data"]["type"]).to eql("user")
        expect(parsed_response["data"]["id"]).to eql(user.id)
        expect(parsed_response["data"]["attributes"]["full_name"]).to eql("John Doe")
        expect(parsed_response["data"]["attributes"]["email"]).to eql("john.doe@example.com")
      end

      context "when user with email address already exists" do
        before do
          User.create!(email: "john.doe@example.com", full_name: "John Doeeeeee")
        end

        it "returns a 409" do
          post "/api/v2/users.json", params: json
          expect(response.code).to eql("409")
        end

        it "does not create another record" do
          expect {
            post "/api/v2/users", params: json
          }.not_to change(User, :count)
        end
      end
    end
  end
end
