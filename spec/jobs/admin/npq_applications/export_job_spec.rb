# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::ExportJob do
  describe "#perform" do
    subject { described_class.new.perform(npq_application_export) }

    let(:npq_application_export) do
      NPQApplications::Export.create(start_date:, end_date:, user: create(:user))
    end

    let(:start_date) { Date.new(2019, 1, 1) }
    let(:end_date) { Date.new(2019, 1, 31) }

    let!(:npq_application_created_within_date_range) { create(:npq_application, created_at: start_date + 1.day) }
    let!(:npq_application_created_before_date_range) { create(:npq_application, created_at: start_date - 1.day) }
    let!(:npq_application_created_after_date_range) { create(:npq_application, created_at: end_date + 1.day) }
    let!(:npq_application_created_on_final_day) { create(:npq_application, created_at: end_date + 12.hours) }

    let(:expected_columns) do
      %i[
        id
        cohort_start_year
        npq_course_id
        npq_lead_provider_id
        npq_course_name
        npq_lead_provider_name
        teacher_catchment
        teacher_catchment_country
        works_in_school
        works_in_childcare
        works_in_nursery
        kind_of_nursery
        headteacher_status
        school_urn
        private_childcare_provider_urn
        school_ukprn
        eligible_for_funding
        funding_eligiblity_status_code
        funding_choice
        employer_name
        employment_role
        employment_type
        targeted_delivery_funding_eligibility
        created_at
        user_id
        user_email
        user_full_name
        teacher_reference_number_verified
        teacher_reference_number
        itt_provider
        lead_mentor
      ]
    end

    let(:expected_csv) do
      applications = [
        npq_application_created_within_date_range,
        npq_application_created_on_final_day,
      ].sort_by(&:id)

      CSV.generate do |csv|
        csv << expected_columns
        applications.each do |application|
          csv << expected_columns.map { |csv_column| application.send(csv_column) }
        end
      end
    end

    let(:parent_folder_id) { SecureRandom.uuid }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GOOGLE_CLIENT_ID").and_return("foo")
      allow(ENV).to receive(:[]).with("GOOGLE_CLIENT_EMAIL").and_return("foo")
      allow(ENV).to receive(:[]).with("GOOGLE_ACCOUNT_TYPE").and_return("foo")
      allow(ENV).to receive(:[]).with("GOOGLE_PRIVATE_KEY").and_return(OpenSSL::PKey::RSA.generate(2048).to_s)
      allow(ENV).to receive(:[]).with("GOOGLE_DRIVE_NPQ_UPLOAD_FOLDER_ID").and_return(parent_folder_id)
    end

    it "sends a csv file to google drive" do
      body_fields = { "token_type" => "Bearer", "expires_in" => 3600, access_token: "1/abcdef1234567890" }
      body = MultiJson.dump body_fields
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(body:,
                   status: 200,
                   headers: { "Content-Type" => "application/json" })

      stub = stub_request(:post, "https://www.googleapis.com/upload/drive/v3/files?supportsAllDrives=true")
               .with(
                 body: "{\"name\":\"npq-applications-2019-01-01-till-2019-01-31-1656675060.csv\",\"parents\":[\"#{parent_folder_id}\"]}",
                 headers: {
                   "Accept" => "*/*",
                   "Accept-Encoding" => "gzip,deflate",
                   "Authorization" => "Bearer 1/abcdef1234567890",
                   "Content-Type" => "application/json",
                   "Date" => "Fri, 01 Jul 2022 11:31:00 GMT",
                   "User-Agent" => /.+/,
                   "X-Goog-Api-Client" => /.+/,
                   "X-Goog-Upload-Command" => "start",
                   "X-Goog-Upload-Header-Content-Length" => expected_csv.length.to_s,
                   "X-Goog-Upload-Header-Content-Type" => "application/octet-stream",
                   "X-Goog-Upload-Protocol" => "resumable",
                 },
               )
               .to_return(status: 200, body: "", headers: {})

      expect(Admin::SecureDriveUploader).to receive(:new).with(
        file: expected_csv,
        filename: "npq-applications-2019-01-01-till-2019-01-31-1656675060.csv",
        folder: parent_folder_id,
      ).and_call_original

      travel_to Time.zone.parse("2022-7-1 11:31") do
        subject
      end

      expect(stub).to have_been_requested
    end
  end
end
