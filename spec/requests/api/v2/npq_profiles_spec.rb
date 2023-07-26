# frozen_string_literal: true

require "rails_helper"

class DummyToken < ApiToken
  def owner
    "Test"
  end
end

RSpec.describe "NPQ profiles api endpoint", type: :request do
  let!(:default_schedule) { create(:npq_specialist_schedule) }
  let(:token) { NPQRegistrationApiToken.create_with_random_token! }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }
  let!(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }

  describe "#show" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers["Content-Type"] = "application/vnd.api+json"
    end

    let(:npq_application) { create(:npq_application) }

    it "displays the application attributes" do
      get "/api/v2/npq-profiles/#{npq_application.id}"
      expect(response).to be_ok
      expect(JSON.parse(response.body)).to match(
        hash_including(
          "data" => hash_including(
            "id", "type", "attributes"
          ),
        ),
      )
    end
  end

  describe "#update" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers["Content-Type"] = "application/vnd.api+json"
    end

    let(:json) { json_hash.to_json }
    let(:npq_application) { create(:npq_application, eligible_for_funding: false) }

    context "with valid data" do
      let(:json_hash) do
        {
          data: {
            type: "npq_profiles",
            attributes: {
              eligible_for_funding: true,
            },
          },
        }
      end

      it "updates the record" do
        expect { patch "/api/v2/npq-profiles/#{npq_application.id}", params: json }
          .to change { npq_application.reload.eligible_for_funding }
          .from(false)
          .to(true)

        expect(response).to be_ok
      end
    end

    context "with invalid data" do
      let(:json_hash) do
        {
          data: {
            type: "npq_profiles",
            attributes: {
              eligible_for_funding: "moose",
            },
          },
        }
      end

      it "returns an error" do
        expect { patch "/api/v2/npq-profiles/#{npq_application.id}", params: json }
          .to_not change { npq_application.reload.eligible_for_funding }

        expect(response).to be_bad_request
      end
    end

    context "with no changed data" do
      let(:json_hash) do
        {
          data: {
            type: "npq_profiles",
            attributes: {},
          },
        }
      end

      it "doesn't change anything and returns ok" do
        expect { patch "/api/v2/npq-profiles/#{npq_application.id}", params: json }
          .to_not change { npq_application.reload.attributes }

        expect(response).to be_ok
      end
    end
  end

  describe "#create" do
    let(:user) { create(:user) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers["Content-Type"] = "application/vnd.api+json"
      end

      let(:json_hash) do
        {
          data: {
            type: "npq_profiles",
            attributes: {
              teacher_reference_number: "1234567",
              teacher_reference_number_verified: true,
              active_alert: true,
              date_of_birth: "1990-12-13",
              national_insurance_number: "AB123456C",
              school_urn: "123456",
              school_ukprn: "12345678",
              headteacher_status: "no",
              eligible_for_funding: true,
              funding_choice: "school",
            },
            relationships: {
              user: {
                data: {
                  type: "users",
                  id: user.id,
                },
              },
              npq_lead_provider: {
                data: {
                  type: "npq_lead_providers",
                  id: npq_lead_provider.id,
                },
              },
              npq_course: {
                data: {
                  type: "npq_courses",
                  id: npq_course.id,
                },
              },
            },
          },
        }
      end

      let(:json) { json_hash.to_json }

      it "creates the npq validation data" do
        Timecop.freeze(Date.new(2023, 3, 20)) do
          expect { post "/api/v2/npq-profiles", params: json }
            .to change(NPQApplication, :count).by(1)

          npq_application = NPQApplication.order(created_at: :desc).first

          expect(npq_application.user).to eql(user)

          expect(npq_application.npq_lead_provider).to eql(npq_lead_provider)
          expect(npq_application.date_of_birth).to eql(Date.new(1990, 12, 13))
          expect(npq_application.nino).to eql("AB123456C")
          expect(npq_application.teacher_reference_number).to eql("1234567")
          expect(npq_application.teacher_reference_number_verified).to be_truthy
          expect(npq_application.active_alert).to be_truthy
          expect(npq_application.school_urn).to eql("123456")
          expect(npq_application.school_ukprn).to eql("12345678")
          expect(npq_application.headteacher_status).to eql("no")
          expect(npq_application.npq_course).to eql(npq_course)
          expect(npq_application.eligible_for_funding).to eql(true)
          expect(npq_application.funding_choice).to eql("school")
          expect(npq_application.lead_provider_approval_status).to eql("pending")
          expect(npq_application.cohort_id).to eql(cohort_2022.id)
        end
      end

      it "returns a 201" do
        post "/api/v2/npq-profiles", params: json
        expect(response).to be_created
      end

      it "returns correct jsonapi content type header" do
        post "/api/v2/npq-profiles", params: json
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns correct type" do
        post "/api/v2/npq-profiles", params: json
        expect(parsed_response["data"]).to have_type("npq_profiles")
      end

      it "response has correct attributes" do
        post "/api/v2/npq-profiles", params: json

        npq_application = NPQApplication.order(created_at: :desc).first

        expect(parsed_response["data"]["id"]).to eql(npq_application.id)
        expect(parsed_response["data"]).to have_jsonapi_attributes(
          :teacher_reference_number,
          :headteacher_status,
          :date_of_birth,
          :school_urn,
          :school_ukprn,
          :eligible_for_funding,
          :funding_choice,
        )
      end

      context "cannot perform save" do
        before do
          json_hash[:data][:relationships][:user][:data][:id] = nil
          json_hash[:data][:relationships][:npq_lead_provider][:data][:id] = nil
          json_hash[:data][:relationships][:npq_course][:data][:id] = nil
        end

        it "returns errors" do
          post "/api/v2/npq-profiles", params: json

          expect(parsed_response["errors"]).to be_present
        end
      end
    end

    context "when unauthorized" do
      it "returns 401" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v2/npq-profiles"
        expect(response.status).to eq 401
      end
    end

    context "using valid token but for different scope" do
      let(:other_token) { DummyToken.create_with_random_token! }

      it "returns 403" do
        default_headers[:Authorization] = "Bearer #{other_token}"
        post "/api/v2/npq-profiles"
        expect(response.status).to eq 403
      end
    end
  end
end
