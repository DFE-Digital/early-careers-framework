# frozen_string_literal: true

module Schools
  class AddParticipantsController < ::Schools::BaseController
    FORM_SESSION_KEY = :add_participant_form
    FORM_PARAM_KEY = :schools_add_participant_form

    skip_after_action :verify_authorized
    before_action :set_school_cohort

    helper_method :add_participant_form

    def start
      session.delete(FORM_SESSION_KEY)
      redirect_to action: :show, step: :type
    end

    def show
      render current_step
    end

    def update
      if add_participant_form.valid?(current_step)
        add_participant_form.record_completed_step current_step
        store_form_in_session
        redirect_to action: :show, step: step_param(add_participant_form.next_step(current_step))
      elsif add_participant_form.email_already_taken?
        @is_same_school = User.find_by(email: add_participant_form.email).school == current_user.school
        render "email_taken"
      else
        render current_step
      end
    end

  private

    def add_participant_form
      return @add_participant_form if defined?(@add_participant_form)

      @add_participant_form = AddParticipantForm.new(session[FORM_SESSION_KEY])
      @add_participant_form.assign_attributes(add_participant_form_params) if params[FORM_PARAM_KEY]

      @add_participant_form
    end

    def store_form_in_session
      session[FORM_SESSION_KEY] = add_participant_form.attributes
    end

    def current_step
      params[:step].tr("-", "_").to_sym
    end

    def step_param(step)
      step.to_s.tr("_", "-")
    end

    def back_link_path
      previous_step = add_participant_form.previous_step(current_step)
      return schools_cohort_participants_path unless previous_step

      { action: :show, step: step_param(previous_step) }
    end

    def add_participant_form_params
      params.require(FORM_PARAM_KEY).permit(:type, :full_name, :email)
    end

    helper_method :back_link_path
  end
end
