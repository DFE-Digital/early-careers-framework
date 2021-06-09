# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseController < ::Schools::BaseController
      FORM_SESSION_KEY = :add_participant_form
      FORM_PARAM_KEY = :schools_add_participant_form

      skip_after_action :verify_authorized
      before_action :set_school_cohort

      helper_method :add_participant_form

      def start
        session.delete(FORM_SESSION_KEY)
        redirect_to schools_cohort_add_participants_type_path
      end

    private

      def add_participant_form
        return @add_participant_form if defined?(@add_participant_form)

        @add_participant_form = AddParticipantForm.new(session[FORM_SESSION_KEY])
        @add_participant_form.assign_attributes(params.require(FORM_PARAM_KEY).permit!) if params[FORM_PARAM_KEY]

        @add_participant_form
      end

      def store_form_in_session
        session[FORM_SESSION_KEY] = add_participant_form.attributes
      end
    end
  end
end
