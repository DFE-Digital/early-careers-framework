# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeadProviders::PartnershipCsvUploads", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }

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
      it "creates the partnership_csv_upload and redirects to csv error page" do
        set_session(:delivery_partner_id, delivery_partner.id)
        form_params = {
          partnership_csv_upload: {
            csv: Rack::Test::UploadedFile.new(file_fixture("school_urns.csv"), "text/csv"),
          },
        }
        post lead_providers_report_schools_partnership_csv_uploads_path, params: form_params

        expect(response).to redirect_to errors_lead_providers_report_schools_partnership_csv_uploads_path
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
        post lead_providers_report_schools_partnership_csv_uploads_path, params: form_params

        expect(response).to redirect_to lead_providers_report_schools_confirm_schools_path
      end
    end
  end

  describe "GET /lead-providers/partnership-csv-uploads/errors" do
    before do
      upload = create(:partnership_csv_upload, :with_csv)
      set_session(:partnership_csv_upload_id, upload.id)
    end

    it "renders the errors template" do
      get errors_lead_providers_report_schools_partnership_csv_uploads_path
      expect(response).to render_template("lead_providers/partnership_csv_uploads/errors")
    end
  end
end
