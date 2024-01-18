# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "NPQ Applications API", type: :request do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:another_npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }

  describe "GET /api/v1/npq-applications" do
    let(:other_npq_lead_provider) { create(:npq_lead_provider) }

    before :each do
      Timecop.freeze(Time.zone.now) do
        list = []
        list << create_list(:npq_application, 3, :in_private_childcare_provider, npq_lead_provider:, school_urn: "123456", npq_course:)
        list << create_list(:npq_application, 2, npq_lead_provider: other_npq_lead_provider, school_urn: "123456", npq_course:)

        list.flatten.each do |npq_application|
          NPQ::Application::Accept.new(npq_application:).call
        end
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON API" do
        it "returns correct jsonapi content type header" do
          get "/api/v1/npq-applications"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns scoped profiles" do
          get "/api/v1/npq-applications"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v1/npq-applications"
          expect(parsed_response["data"][0]).to have_type("npq_application")
        end

        it "returns correct data" do
          get "/api/v1/npq-applications"

          expect(parsed_response["data"][0]["id"]).to be_in(NPQApplication.pluck(:id))

          profile = NPQApplication.find(parsed_response["data"][0]["id"])
          expect(parsed_response["data"][0]).to eql single_json_v1_application(npq_application: profile)
        end

        it "can return paginated data" do
          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          before do
            create_list :npq_application, 2, npq_lead_provider:, updated_at: 10.days.ago, school_urn: "123456"
          end

          context "with invalid filter of a string" do
            it "returns an error" do
              get "/api/v1/npq-applications", params: { filter: 2.days.ago.iso8601 }
              expect(response).to be_bad_request
              expect(parsed_response).to eql(HashWithIndifferentAccess.new({
                "errors": [
                  {
                    "title": "Bad parameter",
                    "detail": "Filter must be a hash",
                  },
                ],
              }))
            end
          end

          context "with filter[updated_at]" do
            context "with valid filter[updated_at]" do
              it "returns content updated after specified timestamp" do
                get "/api/v1/npq-applications", params: { filter: { updated_since: 2.days.ago.iso8601 } }
                expect(parsed_response["data"].size).to eql(3)
              end
            end

            context "with invalid filter[updated_at]" do
              it "returns a meaningful error message" do
                get "/api/v1/npq-applications", params: { filter: { updated_since: Date.current.to_s } }

                expect(response).to be_bad_request

                expect(parsed_response).to eql(HashWithIndifferentAccess.new({
                  "errors": [
                    {
                      "title": "Bad request",
                      "detail": "The filter '#/updated_since' must be a valid RCF3339 date",
                    },
                  ],
                }))
              end
            end
          end

          context "with filter[cohort]" do
            let(:next_cohort) { Cohort.next || create(:cohort, :next) }

            before do
              next_cohort.update!(npq_registration_start_date: 20.days.ago)
              @npq_applications_list = create_list(:npq_application, 2, npq_lead_provider:, updated_at: 10.days.ago, school_urn: "123456", cohort: next_cohort)
            end

            it "returns npq applications only for the next cohort" do
              get "/api/v1/npq-applications", params: { filter: { cohort: next_cohort.start_year } }
              expect(parsed_response["data"].size).to eq(2)
              expect(parsed_response["data"].pluck("id")).to match_array(@npq_applications_list.pluck("id"))
            end
          end
        end

        describe "ordering" do
          let!(:oldest_npq_application) { travel_to(1.month.ago) { create(:npq_application, :accepted, npq_lead_provider:, school_urn: "123456", npq_course:) } }

          it "returns all records ordered by npq applications created_at ascending" do
            get "/api/v1/npq-applications"
            expect(parsed_response["data"].size).to eql(4)
            expect(parsed_response.dig("data", 0, "id")).to eql(oldest_npq_application.id)
          end
        end
      end

      describe "NPQ Registration Proxy JSON API" do
        let(:npq_response_body) do
          {
            "data"=> [
              {
                "id"=>"dacd1e38-50e7-48fc-bd3a-1a18d69586f0",
                "type"=>"npq_application",
                "attributes"=> {
                  "course_identifier"=>"npq-headship",
                  "email"=>"participant-identity-e91ea672@example.com",
                  "email_validated"=>true,
                  "employer_name"=>"Learning Partnership West Independent School",
                  "employment_role"=>"Vocational Leader",
                  "full_name"=>"Librada Boehm VM",
                  "funding_choice"=>"self",
                  "headteacher_status"=>"yes_in_first_five_years",
                  "ineligible_for_funding_reason"=>"establishment-ineligible",
                  "participant_id"=>"1a61653f-79f4-47dc-87cb-c9e876c298bb",
                  "private_childcare_provider_urn"=>nil,
                  "teacher_reference_number"=>nil,
                  "teacher_reference_number_validated"=>false,
                  "school_urn"=>nil,
                  "school_ukprn"=>nil,
                  "status"=>"pending",
                  "works_in_school"=>false,
                  "created_at"=>"1968-06-12T00:00:00Z",
                  "updated_at"=>"2023-11-13T15:36:07Z",
                  "cohort"=>"2021",
                  "eligible_for_funding"=>false,
                  "targeted_delivery_funding_eligibility"=>false,
                  "teacher_catchment"=>true,
                  "teacher_catchment_iso_country_code"=>nil,
                  "teacher_catchment_country"=>nil,
                  "itt_provider"=>nil,
                  "lead_mentor"=>false,
                },
              },
            ],
          }
        end

        before do
          stub_request(:get, "http://npq_registration.example.com:443/api/v1/npq-applications").with(
            headers: {
              "Accept"=>"*/*",
              "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Authorization" => bearer_token,
              "Host"=>"npq_registration.example.com",
              "User-Agent"=>"Ruby",
            },
          ).to_return(status: 200, body: npq_response_body.to_json, headers: {})
        end

        it "returns correct jsonapi content type header" do
          get "/api/v1/npq-applications"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response["data"][0]["id"]).to eql(npq_response_body["data"][0]["id"])
          expect(parsed_response["data"][0]).to have_type("npq_application")
        end
      end

      describe "CSV API" do
        let(:parsed_response) { CSV.parse(response.body, headers: true) }

        before do
          get "/api/v1/npq-applications.csv"
        end

        it "returns the correct CSV content type header" do
          expect(response.headers["Content-Type"]).to eql("text/csv")
        end

        it "returns scoped profiles" do
          expect(parsed_response.length).to eql(NPQApplication.where(npq_lead_provider:).count)
        end

        it "returns the correct headers" do
          expect(parsed_response.headers).to match_array(
            %w[
              id
              participant_id
              full_name
              email
              email_validated
              teacher_reference_number
              teacher_reference_number_validated
              school_urn
              school_ukprn
              private_childcare_provider_urn
              headteacher_status
              eligible_for_funding
              funding_choice
              course_identifier
              status
              works_in_school
              employer_name
              employment_role
              created_at
              updated_at
              cohort
              ineligible_for_funding_reason
              targeted_delivery_funding_eligibility
              teacher_catchment
              teacher_catchment_country
              teacher_catchment_iso_country_code
              itt_provider
              lead_mentor
            ],
          )
        end

        it "returns correct data" do
          application = npq_lead_provider.npq_applications[0]
          row = parsed_response[0]

          expect(row["id"]).to eql(application.id)
          expect(row["participant_id"]).to eql(application.user.id)
          expect(row["full_name"]).to eql(application.user.full_name)
          expect(row["email"]).to eql(application.user.email)
          expect(row["email_validated"]).to eql("true")
          expect(row["teacher_reference_number"]).to eql(application.teacher_reference_number)
          expect(row["teacher_reference_number_validated"]).to eql(application.teacher_reference_number_verified.to_s)
          expect(row["school_urn"]).to eql(application.school_urn)
          expect(row["school_ukprn"]).to eql(application.school_ukprn)
          expect(row["private_childcare_provider_urn"]).to eql(application.private_childcare_provider_urn)
          expect(row["headteacher_status"]).to eql(application.headteacher_status)
          expect(row["eligible_for_funding"]).to eql(application.eligible_for_funding.to_s)
          expect(row["funding_choice"]).to eql(application.funding_choice)
          expect(row["course_identifier"]).to eql(application.npq_course.identifier)
          expect(row["status"]).to eql(application.lead_provider_approval_status)
          expect(row["works_in_school"]).to eql(application.works_in_school.to_s)
          expect(row["employer_name"]).to eql(application.employer_name)
          expect(row["employment_role"]).to eql(application.employment_role)
          expect(row["itt_provider"]).to eql(application.itt_provider)
          expect(row["lead_mentor"]).to eql(application.lead_mentor.to_s)
          expect(row["created_at"]).to eql(application.created_at.rfc3339)
          expect(row["updated_at"]).to eql(application.updated_at.rfc3339)
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/npq-applications"
        expect(response.status).to eq 401
      end
    end

    context "when token belongs to provider that does not handle NPQs" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider:) }
      let(:lead_provider) { create(:lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
      let(:bearer_token) { "Bearer #{token}" }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/npq-applications"
        expect(response.status).to eq 403
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/npq-applications"
        expect(response.status).to eq 403
      end
    end
  end

  describe "GET /api/v1/npq-applications/:id" do
    let(:npq_application) { create(:npq_application, npq_lead_provider:) }

    before do
      default_headers[:Authorization] = bearer_token
      get "/api/v1/npq-applications/#{npq_application.id}"
    end

    context "when authorized" do
      let(:expected_response) { expected_single_json_v1_response(npq_application:) }

      it "returns correct jsonapi content type header" do
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns 200" do
        expect(response.status).to eq 200
      end

      it "returns correct data" do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context "when unauthorized" do
      let(:token) { "wrong_token" }

      it "returns 401 for invalid bearer token" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "POST /api/v1/npq-applications/:id/reject" do
    let(:npq_profile) { create(:npq_application, npq_lead_provider:) }

    before do
      default_headers[:Authorization] = bearer_token
    end

    it "update lead_provider_approval_status to rejected" do
      expect { post "/api/v1/npq-applications/#{npq_profile.id}/reject" }
        .to change { npq_profile.reload.lead_provider_approval_status }.from("pending").to("rejected")
    end

    it "responds with 200 and representation of the resource" do
      post "/api/v1/npq-applications/#{npq_profile.id}/reject"

      expect(response).to be_successful

      expect(parsed_response.dig("data", "attributes", "status")).to eql("rejected")
    end

    context "application has been accepted" do
      let(:npq_profile) { create(:npq_application, npq_lead_provider:, lead_provider_approval_status: "accepted") }

      it "return 422" do
        post "/api/v1/npq-applications/#{npq_profile.id}/reject"

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error in repsonse" do
        post "/api/v1/npq-applications/#{npq_profile.id}/reject"

        expect(parsed_response.key?("errors")).to be_truthy
        expect(parsed_response["errors"][0]["title"]).to eql("npq_application")
        expect(parsed_response.dig("errors", 0, "detail")).to eql("Once accepted an application cannot change state")
      end
    end
  end

  describe "POST /api/v1/npq-applications/:id/accept" do
    let(:default_npq_application) { create(:npq_application, npq_lead_provider:, npq_course:) }
    let(:user) { default_npq_application.user }

    before do
      default_headers[:Authorization] = bearer_token
    end

    it "update status to accepted" do
      expect { post "/api/v1/npq-applications/#{default_npq_application.id}/accept" }
        .to change { default_npq_application.reload.lead_provider_approval_status }.from("pending").to("accepted")
    end

    it "responds with 200 and representation of the resource" do
      post "/api/v1/npq-applications/#{default_npq_application.id}/accept"

      expect(response).to be_successful

      expect(parsed_response.dig("data", "attributes", "status")).to eql("accepted")
    end

    context "when participant has applied for multiple NPQs" do
      let(:participant_identity) { default_npq_application.participant_identity }
      let!(:other_npq_application) { create(:npq_application, npq_course:, npq_lead_provider:, participant_identity:) }
      let!(:other_accepted_npq_application) { create(:npq_application, npq_course: another_npq_course, npq_lead_provider:, participant_identity:, lead_provider_approval_status: "accepted") }

      it "rejects all pending NPQs on same course" do
        post "/api/v1/npq-applications/#{default_npq_application.id}/accept"

        expect(other_npq_application.reload.lead_provider_approval_status).to eql("rejected")
      end

      it "does not reject non-pending NPQs on same course" do
        post "/api/v1/npq-applications/#{default_npq_application.id}/accept"

        expect(other_accepted_npq_application.reload.lead_provider_approval_status).to eql("accepted")
      end
    end

    context "application has been rejected" do
      let(:npq_profile) { create(:npq_application, npq_lead_provider:, lead_provider_approval_status: "rejected", npq_course:) }

      it "return 422" do
        post "/api/v1/npq-applications/#{npq_profile.id}/accept"

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error in response" do
        post "/api/v1/npq-applications/#{npq_profile.id}/accept"

        expect(parsed_response.key?("errors")).to be_truthy
        expect(parsed_response.dig("errors", 0, "detail")).to eql("Once rejected an application cannot change state")
      end
    end

    describe "NPQ Registration Proxy JSON API" do
      let(:npq_response_body) do
        {
          "data"=> {
            "id"=> default_npq_application.id,
            "type"=>"npq_application",
            "attributes"=> {
              "status"=>"accepted",
            },
          },
        }
      end

      before do
        stub_request(:post, "http://npq_registration.example.com:443/api/v1/npq-applications/#{default_npq_application.id}/accept")
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

      it "responds with 200 and representation of the resource" do
        post "/api/v1/npq-applications/#{default_npq_application.id}/accept"

        expect(response).to be_successful

        expect(parsed_response.dig("data", "attributes", "status")).to eql("accepted")
      end
    end
  end
end

def expected_single_json_v1_response(npq_application:)
  {
    "data" =>
        single_json_v1_application(npq_application:),
  }
end

def single_json_v1_application(npq_application:)
  {
    "id" => npq_application.id,
    "type" => "npq_application",
    "attributes" => {
      "course_identifier" => npq_application.npq_course.identifier,
      "email" => npq_application.user.email,
      "email_validated" => true,
      "employer_name" => npq_application.employer_name,
      "employment_role" => npq_application.employment_role,
      "full_name" => npq_application.user.full_name,
      "funding_choice" => npq_application.funding_choice,
      "headteacher_status" => npq_application.headteacher_status,
      "ineligible_for_funding_reason" => npq_application.ineligible_for_funding_reason,
      "participant_id" => npq_application.participant_identity.external_identifier,
      "private_childcare_provider_urn" => npq_application.private_childcare_provider_urn,
      "teacher_reference_number" => npq_application.teacher_reference_number,
      "teacher_reference_number_validated" => npq_application.teacher_reference_number_verified,
      "school_urn" => npq_application.school_urn,
      "school_ukprn" => npq_application.school_ukprn,
      "status" => npq_application.lead_provider_approval_status,
      "works_in_school" => npq_application.works_in_school,
      "created_at" => npq_application.created_at.rfc3339,
      "updated_at" => npq_application.updated_at.rfc3339,
      "cohort" => npq_application.cohort.start_year.to_s,
      "eligible_for_funding" => npq_application.eligible_for_funding,
      "targeted_delivery_funding_eligibility" => npq_application.targeted_delivery_funding_eligibility,
      "teacher_catchment" => true,
      "teacher_catchment_country" => npq_application.teacher_catchment_country,
      "teacher_catchment_iso_country_code" => npq_application.teacher_catchment_iso_country_code,
      "itt_provider" => npq_application.itt_provider,
      "lead_mentor" => npq_application.lead_mentor,
    },
  }
end
