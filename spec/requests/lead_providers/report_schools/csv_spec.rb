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
      it "renders :new with error message" do
        expect_any_instance_of(AnalyticsDataLayer).to receive(:add).with(csv_file_errors: %w[please_select_a_csv_file_to_upload])

        post "/lead-providers/report-schools/csv", params: {}

        expect(response).to render_template :show
        expect(response.body).to include("Select a CSV file to upload")
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

        PartnershipCsvUpload.last.tap do |upload|
          expect(upload.lead_provider_id).to eq(user.lead_provider_profile.lead_provider.id)
          expect(upload.delivery_partner_id).to eq(delivery_partner.id)
          expect(upload.uploaded_urns).to eql(file_fixture("school_urns.csv").read.lines(chomp: true))
        end
      end

      it "redirects to the confirm page when there are no errors" do
        csv_contents = StringIO.new(create_list(:school, 5).map(&:urn).join("\n"))

        set_session(:delivery_partner_id, delivery_partner.id)

        form_params = {
          partnership_csv_upload: {
            csv: Rack::Test::UploadedFile.new(csv_contents, "text/csv", original_filename: "test.csv"),
          },
        }
        post "/lead-providers/report-schools/csv", params: form_params

        expect(response).to redirect_to lead_providers_report_schools_confirm_path
      end
    end
  end

  describe "GET /lead-providers/report-schools/csv/errors" do
    before do
      upload = create(:partnership_csv_upload, cohort:, lead_provider: user.lead_provider, delivery_partner:)
      set_session(:partnership_csv_upload_id, upload.id)
    end

    it "renders the errors template" do
      get "/lead-providers/report-schools/csv/errors"
      expect(response).to render_template :errors
    end

    it "adds the correct values to the data layer" do
      expect_any_instance_of(AnalyticsDataLayer).to receive(:add).with(
        csv_rows_with_errors: 4,
        csv_valid_rows: 0,
        csv_errors: { "urn_is_not_valid" => 4 },
      )

      get "/lead-providers/report-schools/csv/errors"
    end
  end
end
