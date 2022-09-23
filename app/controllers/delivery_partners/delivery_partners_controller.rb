# frozen_string_literal: true

module DeliveryPartners
  class DeliveryPartnersController < BaseController
    layout "application"

    def index
      if choose_organisation_form.only_one
        redirect_to delivery_partner_participants_path(choose_organisation_form.delivery_partner)
      end
    end

    def create
      choose_organisation_form.assign_attributes(choose_organisation_form_params)

      if choose_organisation_form.valid?
        redirect_to delivery_partner_participants_path(choose_organisation_form.delivery_partner)
      else
        render :index
      end
    end

  private

    def choose_organisation_form
      @choose_organisation_form ||= ChooseOrganisationForm.new(user: current_user)
    end

    def choose_organisation_form_params
      params.fetch(:delivery_partners_choose_organisation_form, {}).permit(
        :delivery_partner_id,
      )
    end
  end
end
