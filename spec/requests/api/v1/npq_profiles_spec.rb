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
  let!(:cohort_2021) { Cohort.current || create(:cohort, :current) }
  let!(:cohort_2022) { create(:cohort, :next) }

  describe "#show" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers["Content-Type"] = "application/vnd.api+json"
    end

    let(:npq_application) { create(:npq_application) }

    it "displays the application attributes" do
      get "/api/v1/npq-profiles/#{npq_application.id}"
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
              funding_eligiblity_status_code: "funded",
              teacher_catchment: "other",
              teacher_catchment_country: "United Kingdom",
            },
          },
        }
      end

      it "updates the record" do
        expect { patch "/api/v1/npq-profiles/#{npq_application.id}", params: json }
          .to change {
            npq_application.reload.slice(
              :eligible_for_funding,
              :funding_eligiblity_status_code,
              :teacher_catchment,
              :teacher_catchment_country,
            )
          }
          .from({
            eligible_for_funding: false,
            funding_eligiblity_status_code: "ineligible_establishment_type",
            teacher_catchment: nil,
            teacher_catchment_country: nil,
          })
          .to({
            eligible_for_funding: true,
            funding_eligiblity_status_code: "funded",
            teacher_catchment: "other",
            teacher_catchment_country: "United Kingdom",
          })

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
        expect { patch "/api/v1/npq-profiles/#{npq_application.id}", params: json }
          .to_not change { npq_application.reload.slice(:eligible_for_funding, :funding_eligiblity_status_code) }

        expect(response).to be_bad_request
      end
    end

    context "with no changed data" do
      let(:json_hash) do
        {
          data: {
            type: "npq_profiles",
            attributes: {
            },
          },
        }
      end

      it "doesn't change anything and returns ok" do
        expect { patch "/api/v1/npq-profiles/#{npq_application.id}", params: json }
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
              targeted_delivery_funding_eligibility: true,
              cohort: cohort_2022.start_year,
              employer_name: nil,
              employment_role: nil,
              works_in_school: "true",
              works_in_nursery: "false",
              works_in_childcare: "false",
              kind_of_nursery: nil,
              private_childcare_provider_urn: nil,
              funding_eligiblity_status_code: "funded",
              teacher_catchment: "other",
              teacher_catchment_country: "United Kingdom",
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
        expect { post "/api/v1/npq-profiles", params: json }
          .to change(NPQApplication, :count).by(1)

        npq_application = NPQApplication.order(created_at: :desc).first

        application_as_json = npq_application.as_json(except: %i[
          id
          created_at
          updated_at
          participant_identity_id
          targeted_support_funding_eligibility
        ])

        expect(application_as_json).to match({
          "npq_lead_provider_id" => npq_lead_provider.id,
          "date_of_birth" => "1990-12-13",
          "nino" => "AB123456C",
          "teacher_reference_number" => "1234567",
          "teacher_reference_number_verified" => true,
          "active_alert" => true,
          "school_urn" => "123456",
          "school_ukprn" => "12345678",
          "headteacher_status" => "no",
          "npq_course_id" => npq_course.id,
          "eligible_for_funding" => true,
          "funding_choice" => "school",
          "lead_provider_approval_status" => "pending",
          "targeted_delivery_funding_eligibility" => true,
          "cohort_id" => cohort_2022.id,
          "employer_name" => nil,
          "employment_role" => nil,
          "works_in_school" => true,
          "works_in_nursery" => false,
          "works_in_childcare" => false,
          "kind_of_nursery" => nil,
          "private_childcare_provider_urn" => nil,
          "funding_eligiblity_status_code" => "funded",
          "teacher_catchment" => "other",
          "teacher_catchment_country" => "United Kingdom",
        })
      end

      it "returns a 201" do
        post "/api/v1/npq-profiles", params: json
        expect(response).to be_created
      end

      it "returns correct jsonapi content type header" do
        post "/api/v1/npq-profiles", params: json
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns correct type" do
        post "/api/v1/npq-profiles", params: json
        expect(parsed_response["data"]).to have_type("npq_profiles")
      end

      it "response has correct attributes" do
        post "/api/v1/npq-profiles", params: json

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
          post "/api/v1/npq-profiles", params: json

          expect(parsed_response["errors"]).to be_present
        end
      end
    end

    context "when unauthorized" do
      it "returns 401" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v1/npq-profiles"
        expect(response.status).to eq 401
      end
    end

    context "using valid token but for different scope" do
      let(:other_token) { DummyToken.create_with_random_token! }

      it "returns 403" do
        default_headers[:Authorization] = "Bearer #{other_token}"
        post "/api/v1/npq-profiles"
        expect(response.status).to eq 403
      end
    end
  end
end
