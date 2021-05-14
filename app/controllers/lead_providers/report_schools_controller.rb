# frozen_string_literal: true

module LeadProviders
  class ReportSchoolsController < ::LeadProviders::BaseController
    def start
      session.delete(:delivery_partner_id)
    end

    def choose_delivery_partner
      @delivery_partner_form = LeadProviderDeliveryPartnerForm.new
      @delivery_partners = current_user.lead_provider.delivery_partners
    end

    def check_delivery_partner
      @delivery_partner_form = LeadProviderDeliveryPartnerForm.new(
        params.require(:lead_provider_delivery_partner_form).permit(:delivery_partner_id),
      )

      if @delivery_partner_form.valid?
        session[:delivery_partner_id] = @delivery_partner_form.delivery_partner_id
        redirect_to new_lead_providers_report_schools_partnership_csv_uploads_path
      else
        @delivery_partners = current_user.lead_provider.delivery_partners
        render :choose_delivery_partner
      end
    end

    def success
      @confirm_schools_form = ConfirmSchoolsForm.new(session.delete(:confirm_schools_form))
      session.delete(:delivery_partner_id)
    end
  end
end
