# frozen_string_literal: true

module AppropriateBodies
  class AppropriateBodiesController < BaseController
    layout "application"

    def index
      @choose_organisation_form = ChooseOrganisationForm.new
      @choose_organisation_form.user = current_user

      if @choose_organisation_form.only_one?
        redirect_to appropriate_body_participants_path(@choose_organisation_form.appropriate_body)
      end
    end

    def create
      @choose_organisation_form = ChooseOrganisationForm.new(choose_organisation_form_params)
      @choose_organisation_form.user = current_user

      if @choose_organisation_form.valid?
        redirect_to appropriate_body_participants_path(@choose_organisation_form.appropriate_body)
      else
        render :index
      end
    end

  private

    def choose_organisation_form_params
      params.fetch(:appropriate_bodies_choose_organisation_form, {}).permit(
        :appropriate_body_id,
      )
    end
  end
end
