# frozen_string_literal: true

module Wizard
  module Controller
    extend ActiveSupport::Concern

    def show
      render @wizard.current_step(params)

      # @wizard.before_render

      # render @wizard.current_step

      # @wizard.after_render
    end

    def update
      if @wizard.valid?
        # if @form.valid?
        @wizard.save!

        redirect_to @wizard.next_step_path
        # redirect_to add_participant_wizard_show_schools_participants_path(cohort_id: @school_cohort.cohort.start_year, step: @wizard.next_step_path)
      else
        render @wizard.current_step(params)
      end
    end

    # def complete
    #   remove_session_data
    #   @profile = ParticipantProfile.find(params[:participant_profile_id])
    # end

    # def set_wizard_form
    #   if request.get?
    #     @wizard = form_class.new(current_step: step_name, current_state:, current_user:, school_cohort: @school_cohort)
    #     @wizard.changing_answer(params["changing_answer"] == "1")
    #   else
    #     @wizard = form_class.new(current_step: step_name, current_state:, current_user:, school_cohort: @school_cohort, submitted_params:)
    #   end
    #   @form = @wizard.form
    # end

    def current_state
      session[@form_name] ||= {}
    end

    def step_name
      params[:step]&.underscore
    end

    def submitted_params
      params.fetch(@form_name, {}).permit(@form_class.permitted_params_for(step_name))
    end

    def reset_state
      session[@form_name] = {}
      @wizard&.set_current_state(current_state)
    end

    def remove_session_data
      session.delete(@form_name)
    end

    def abandon_journey_path
      @wizard.abandon_path
    end

    def verify_session_or_escape
      redirect_to abandon_journey_path unless session.key?(@form_name)
    end
  end
end
