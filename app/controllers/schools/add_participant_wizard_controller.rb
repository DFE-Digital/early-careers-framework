# frozen_string_literal: true

module Schools
  class AddParticipantWizardController < ::Schools::BaseController
    before_action :set_school_cohort

    def show
      @wizard = AddParticipantWizard.new(current_step: step_name, current_state:, current_user:)
      @form = @wizard.form

      @wizard.before_render

      render @wizard.current_step

      @wizard.after_render
    end

    def update
      @wizard = AddParticipantWizard.new(current_step: step_name, current_state:, current_user:, submitted_params:)
      @wizard.changing_answer! if params["changing_answer"] == "1"
      @form = @wizard.form
      
      if @form.valid?
        @wizard.save!
        redirect_to add_participant_wizard_show_schools_participants_path(cohort_id: @school_cohort.cohort.start_year, step: @wizard.next_step_path)
      else
        render @wizard.current_step
      end
    end

  private
  
    def current_state
      session[:add_participant_wizard] ||= {}
    end

    def step_name
      params[:step]&.underscore || "who"
    end

    def submitted_params
      params.fetch(:add_participant_wizard, {}).permit(AddParticipantWizard.permitted_params_for(step_name))
    end

    def reset_state
      session.delete(:add_participant_wizard)
    end
  end
end
