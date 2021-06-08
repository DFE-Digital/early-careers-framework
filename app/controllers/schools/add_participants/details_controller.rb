# frozen_string_literal: true

module Schools::AddParticipants
  class DetailsController < BaseController
    def show; end

    def update
      if add_participant_form.valid?(:details)
        store_form_in_session
        render html: "Further steps not implemented", layout: true
      else
        render :show
      end
    end
  end
end
