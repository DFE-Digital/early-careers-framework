# frozen_string_literal: true

module LeadProviders
  class PartnershipCsvUploadsController < ::LeadProviders::BaseController
    def new
      @partnership_csv_upload = PartnershipCsvUpload.new
    end

    def create
      if params[:partnership_csv_upload].blank?
        @partnership_csv_upload = PartnershipCsvUpload.new
        @partnership_csv_upload.errors.add(:base, "Please select a CSV file to upload.")
        render :new and return
      end

      @partnership_csv_upload = PartnershipCsvUpload.new(
        upload_params.merge(
          lead_provider_id: current_user.lead_provider_profile.lead_provider.id,
          delivery_partner_id: session[:delivery_partner_id],
        ),
      )

      if @partnership_csv_upload.save
        session[:partnership_csv_upload_id] = @partnership_csv_upload.id
        if @partnership_csv_upload.invalid_schools.empty?
          redirect_to lead_providers_report_schools_confirm_schools_path
        else
          redirect_to errors_lead_providers_report_schools_partnership_csv_uploads_path
        end
      else
        render :new
      end
    end

    def errors
      partnership_csv_upload = PartnershipCsvUpload.find(session[:partnership_csv_upload_id])
      @urns = partnership_csv_upload.urns
      @errors = partnership_csv_upload.invalid_schools
      @valid_schools = partnership_csv_upload.valid_schools
    end

  private

    def upload_params
      params.require(:partnership_csv_upload).permit(:csv)
    end
  end
end
