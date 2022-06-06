# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "NPQ Applications API", :with_default_schedules, type: :request do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:another_npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }

  describe "GET /api/v1/npq-applications" do
    let(:other_npq_lead_provider) { create(:npq_lead_provider) }

    before :each do
      list = []
      list << create_list(:npq_application, 3, :in_private_childcare_provider, npq_lead_provider: npq_lead_provider, school_urn: "123456", npq_course: npq_course, cohort: cohort)
      list << create_list(:npq_application, 2, npq_lead_provider: other_npq_lead_provider, school_urn: "123456", npq_course: npq_course, cohort: cohort)

      list.flatten.each do |npq_application|
        NPQ::Accept.new(npq_application: npq_application).call
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
          user = User.find(parsed_response["data"][0]["attributes"]["participant_id"])

          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)
          expect(parsed_response["data"][0]["attributes"]["email"]).to eql(user.email)
          expect(parsed_response["data"][0]["attributes"]["email_validated"]).to eql(true)
          expect(parsed_response["data"][0]["attributes"]["school_urn"]).to eql(profile.school_urn)
          expect(parsed_response["data"][0]["attributes"]["school_ukprn"]).to eql(profile.school_ukprn)
          expect(parsed_response["data"][0]["attributes"]["private_childcare_provider_urn"]).to eql(profile.private_childcare_provider_urn)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(profile.teacher_reference_number)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number_validated"]).to eql(profile.teacher_reference_number_verified)
          expect(parsed_response["data"][0]["attributes"]["eligible_for_funding"]).to eql(profile.eligible_for_funding)
          expect(parsed_response["data"][0]["attributes"]["course_identifier"]).to eql(profile.npq_course.identifier)
          expect(parsed_response["data"][0]["attributes"]["status"]).to eql("accepted")
          expect(parsed_response["data"][0]["attributes"]["works_in_school"]).to eql(profile.works_in_school)
          expect(parsed_response["data"][0]["attributes"]["employment_role"]).to eql(profile.employment_role)
          expect(parsed_response["data"][0]["attributes"]["employer_name"]).to eql(profile.employer_name)
          expect(parsed_response["data"][0]["attributes"]["private_childcare_provider_urn"]).to eql(profile.private_childcare_provider_urn)
        end

        it "can return paginated data" do
          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          context "with filter[updated_at]" do
            before do
              create_list :npq_application, 2, npq_lead_provider: npq_lead_provider, updated_at: 10.days.ago, school_urn: "123456"
            end

            it "returns content updated after specified timestamp" do
              get "/api/v1/npq-applications", params: { filter: { updated_since: 2.days.ago.iso8601 } }
              expect(parsed_response["data"].size).to eql(3)
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
          end

          context "with filter[cohort]" do
            let(:next_cohort) { create(:cohort, :next) }
            let!(:cohort_2022_npq_applications) { create_list :npq_application, 2, npq_lead_provider: npq_lead_provider, updated_at: 10.days.ago, school_urn: "123456", cohort: next_cohort }

            it "returns npq applications only for the 2022 cohort" do
              get "/api/v1/npq-applications", params: { filter: { cohort: 2022 } }
              expect(parsed_response["data"].size).to eq(2)
            end
          end
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
          expect(parsed_response.length).to eql(NPQApplication.where(npq_lead_provider: npq_lead_provider).count)
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
      let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
      let(:lead_provider) { create(:lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
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

  describe "POST /api/v1/npq-applications/:id/reject" do
    let(:npq_profile) { create(:npq_application, npq_lead_provider: npq_lead_provider) }

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
      let(:npq_profile) { create(:npq_application, npq_lead_provider: npq_lead_provider, lead_provider_approval_status: "accepted") }

      it "return 400 bad request " do
        post "/api/v1/npq-applications/#{npq_profile.id}/reject"
        expect(response.status).to eql(400)
      end

      it "returns error in repsonse" do
        post "/api/v1/npq-applications/#{npq_profile.id}/reject"

        expect(parsed_response.key?("errors")).to be_truthy

        expect(parsed_response["errors"][0].key?("title")).to be_truthy
        expect(parsed_response["errors"][0].key?("detail")).to be_truthy
        expect(parsed_response["errors"][0]["title"]).to eql("Status invalid")
        expect(parsed_response["errors"][0]["detail"]).to eql("Once accepted an application cannot change state")
      end
    end
  end

  describe "POST /api/v1/npq-applications/:id/accept" do
    let(:default_npq_application) { create(:npq_application, npq_lead_provider: npq_lead_provider, npq_course: npq_course) }
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
      let!(:other_npq_application) { create(:npq_application, npq_course: npq_course, npq_lead_provider: npq_lead_provider, participant_identity: participant_identity) }
      let!(:other_accepted_npq_application) { create(:npq_application, npq_course: another_npq_course, npq_lead_provider: npq_lead_provider, participant_identity: participant_identity, lead_provider_approval_status: "accepted") }

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
      let(:npq_profile) { create(:npq_application, npq_lead_provider: npq_lead_provider, lead_provider_approval_status: "rejected", npq_course: npq_course) }

      it "return 400 bad request " do
        post "/api/v1/npq-applications/#{npq_profile.id}/accept"
        expect(response.status).to eql(400)
      end

      it "returns error in response" do
        post "/api/v1/npq-applications/#{npq_profile.id}/accept"

        expect(parsed_response.key?("errors")).to be_truthy

        expect(parsed_response["errors"][0].key?("title")).to be_truthy
        expect(parsed_response["errors"][0].key?("detail")).to be_truthy
        expect(parsed_response["errors"][0]["title"]).to eql("Status invalid")
        expect(parsed_response["errors"][0]["detail"]).to eql("Once rejected an application cannot change state")
      end
    end
  end
end
