# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider school reporting: uploading csv", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:cohort) { create(:cohort, :current) }

  before do
    sign_in user

    set_session(LeadProviders::ReportSchools::BaseController::SESSION_KEY, {
      source: :csv,
      delivery_partner_id: delivery_partner.id,
      cohort_id: cohort.id,
      lead_provider_id: user.lead_provider.id,
    })
  end

  describe "GET /lead-providers/report-schools/csv" do
    it "should show the upload csv page to a lead provider" do
      get "/lead-providers/report-schools/csv"

      expect(response).to render_template :show
    end
  end

  describe "POST /lead-providers/report-schools/csv" do
    context "with no file selected" do
      it "renders :new with error mesage" do
        post "/lead-providers/report-schools/csv", params: {}

        expect(response).to render_template :show
        expect(response.body).to include("Please select a CSV file to upload")
      end
    end

    context "with csv file selected" do
      it "creates the partnership_csv_upload and redirects to csv error page" do
        form_params = {
          partnership_csv_upload: {
            csv: Rack::Test::UploadedFile.new(file_fixture("school_urns.csv"), "text/csv"),
          },
        }

        post "/lead-providers/report-schools/csv", params: form_params

        expect(response).to redirect_to errors_lead_providers_report_schools_csv_path

        expect(PartnershipCsvUpload.count).to eq 1
        expect(PartnershipCsvUpload.last.lead_provider_id).to eq(user.lead_provider_profile.lead_provider.id)
        expect(PartnershipCsvUpload.last.delivery_partner_id).to eq(delivery_partner.id)
      end

      it "redirects to the confirm page when there are no errors" do
        schools = create_list(:school, 5)
        file = Tempfile.new
        file.write(schools.map(&:urn).join("\n"))
        file.close
        set_session(:delivery_partner_id, delivery_partner.id)
        form_params = {
          partnership_csv_upload: {
            csv: Rack::Test::UploadedFile.new(File.open(file), "text/csv", original_filename: "test.csv"),
          },
        }
        post "/lead-providers/report-schools/csv", params: form_params

        expect(response).to redirect_to lead_providers_report_schools_confirm_path
      end
    end
  end

  describe "GET /lead-providers/report-schools/csv/errors" do
    before do
      upload = create(:partnership_csv_upload, :with_csv)
      set_session(:partnership_csv_upload_id, upload.id)
    end

    it "renders the errors template" do
      get "/lead-providers/report-schools/csv/errors"
      expect(response).to render_template :errors
    end
  end
end
