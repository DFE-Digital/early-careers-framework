# frozen_string_literal: true

module LeadProviders
  module ReportSchools
    class DeliveryPartnersController < BaseController
      def show; end

      def create
        report_schools_form.assign_attributes(
          params.require(:lead_providers_report_schools_form).permit(:delivery_partner_id),
        )

        if report_schools_form.valid?(:delivery_partner)
          report_schools_form.source = "csv"
          redirect_to lead_providers_report_schools_csv_path
        else
          render :show
        end
      end

    private

      def delivery_partners
        @delivery_partners ||= current_user.lead_provider.delivery_partners
      end
      helper_method :delivery_partners
    end
  end
end
