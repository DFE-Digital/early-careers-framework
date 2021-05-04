# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeadProviders::PartnershipCsvUploads", type: :request do
  let(:user) { create(:user, :lead_provider) }

  before do
    create(:cohort, start_year: 2021)
    sign_in user
  end

  describe "GET /lead-providers/partnership-csv-uploads/new" do
    it "should show the upload csv page to a lead provider" do
      get new_lead_providers_report_schools_partnership_csv_uploads_path

      expect(response).to render_template :new
    end
  end

  describe "POST /lead-providers/partnership-csv-uploads" do
    context "with no file selected" do
      it "renders :new with error mesage" do
        form_params = {}
        post lead_providers_report_schools_partnership_csv_uploads_path, params: form_params

        expect(response).to render_template :new
        expect(response.body).to include("Please select a CSV file to upload")
      end
    end

    context "with csv file selected" do
      it "creates the partnership_csv_upload and redirects to csv errors page" do
        form_params = {
          partnership_csv_upload: {
            csv: Rack::Test::UploadedFile.new(file_fixture("school_urns.csv"), "text/csv"),
          },
        }
        post lead_providers_report_schools_partnership_csv_uploads_path, params: form_params

        expect(response).to redirect_to error_page_lead_providers_report_schools_partnership_csv_uploads_path
        expect(PartnershipCsvUpload.count).to eq 1
      end
    end
  end
end
