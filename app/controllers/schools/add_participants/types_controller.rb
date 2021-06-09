# frozen_string_literal: true

module Schools::AddParticipants
  class TypesController < BaseController
    def show; end

    def update
      if add_participant_form.valid?(:type)
        store_form_in_session
        redirect_to schools_cohort_add_participants_details_path
      else
        render :show
      end
    end
  end
end
