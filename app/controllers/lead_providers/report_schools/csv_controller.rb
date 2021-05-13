# frozen_string_literal: true

module LeadProviders
  module ReportSchools
    class CsvController < BaseController
      def show
        @partnership_csv_upload = PartnershipCsvUpload.new
      end

      def create
        if params[:partnership_csv_upload].blank?
          @partnership_csv_upload = PartnershipCsvUpload.new
          @partnership_csv_upload.errors[:base] << "Please select a CSV file to upload."
          render :show and return
        end

        @partnership_csv_upload = PartnershipCsvUpload.new(
          upload_params.merge(
            lead_provider_id: current_user.lead_provider_profile.lead_provider.id,
            delivery_partner_id: report_schools_form.delivery_partner_id,
          ),
        )

        if @partnership_csv_upload.save
          session[:partnership_csv_upload_id] = @partnership_csv_upload.id
          if @partnership_csv_upload.invalid_schools.empty?
            proceed
          else
            redirect_to action: :errors
          end
        else
          render :show
        end
      end

      def errors
        partnership_csv_upload = PartnershipCsvUpload.find(session[:partnership_csv_upload_id])
        @urns = partnership_csv_upload.urns
        @errors = partnership_csv_upload.invalid_schools
        @valid_schools = partnership_csv_upload.valid_schools
      end

      def proceed
        @partnership_csv_upload ||= PartnershipCsvUpload.find(session[:partnership_csv_upload_id])
        report_schools_form.school_ids = @partnership_csv_upload.valid_schools.pluck(:id)
        session.delete(:partnership_csv_upload_id)
        redirect_to lead_providers_report_schools_confirm_path
      end

    private

      def upload_params
        params.require(:partnership_csv_upload).permit(:csv)
      end
    end
  end
end
