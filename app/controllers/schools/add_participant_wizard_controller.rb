# frozen_string_literal: true

module Schools
  class AddParticipantWizardController < ::Schools::BaseController
    # include Wizard::Controller
    include AppropriateBodySelection::Controller

    before_action :set_school_cohort
    before_action :set_participant_profile, only: :complete
    # before_action :verify_session, except: :complete
    before_action :initialize_wizard, except: :complete

    def show
      @wizard.before_render

      render @wizard.current_step

      @wizard.after_render
    end

    def update
      if @form.valid?
        @wizard.save!

        redirect_to show_schools_add_participants_path(cohort_id: @school_cohort.cohort.start_year, step: @wizard.next_step_path)
      else
        render @wizard.current_step
      end
    end

    def complete
      remove_session_data
    end

    # Appropriate body methods
    def change_appropriate_body
      @wizard.appropriate_body_confirmed = false
      start_appropriate_body_selection
    end

    def save_appropriate_body
      @wizard.appropriate_body_confirmed = false
      @wizard.appropriate_body_id = @appropriate_body_form.body_id

      redirect_to show_schools_add_participants_path(cohort_id: @school_cohort.cohort.start_year, step: "check-answers")
    end

    def start_appropriate_body_selection
      super from_path: url_for(action: :show, step: "confirm-appropriate-body"),
            submit_action: :save_appropriate_body,
            school_name: @school.name,
            ask_appointed: false
    end

    helper_method :wizard_back_link_path

  private

    def set_participant_profile
      @profile = ParticipantProfile.find(params[:participant_profile_id])
    end

    def initialize_wizard
      if request.get?
        @wizard = AddParticipantWizard.new(current_step: step_name,
                                           current_state:,
                                           current_user:,
                                           school_cohort: @school_cohort)

        @wizard.changing_answer(params["changing_answer"] == "1")
      else
        @wizard = AddParticipantWizard.new(current_step: step_name,
                                           current_state:,
                                           current_user:,
                                           school_cohort: @school_cohort,
                                           submitted_params:)
      end
      @form = @wizard.form
    end

    # def verify_session
    #   redirect_to schools_participants_path unless session.key?(:add_partipant_wizard)
    # end

    # def set_wizard
    #   data = request.get? ? {} : submitted_params

    #   @wizard = AddParticipantWizard.new(current_step: step_name, current_state:, current_user:, school_cohort: @school_cohort, submitted_params: data)
    # end

    def wizard_back_link_path
      show_schools_add_participants_path(cohort_id: @school_cohort.cohort.start_year, step: @wizard.previous_step_path)
    end

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
      session[:add_participant_wizard] = {}
      @wizard&.set_current_state(current_state)
    end

    def remove_session_data
      session.delete(:add_participant_wizard)
    end
  end
end
