# frozen_string_literal: true

module Schools
  class CohortSetupController < BaseController
    skip_before_action :redirect_to_setup_cohort
    before_action :initialize_wizard
    before_action :data_check

    def show
      wizard.before_render
      render wizard.view_name
      remove_session_data if wizard.complete?
      wizard.after_render
    end

    def update
      if wizard.valid?
        wizard.save!
        redirect_to wizard.next_step_path
      else
        render wizard.current_step
      end
    end

    helper_method :wizard_back_link_path

  private

    def abort_path
      schools_dashboard_path(school_id: school.slug)
    end

    def cohort
      @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
    end

    def data_check
      remove_session_data if wizard.complete? && !wizard.terminal_step?
    end

    def default_step_name
      :what_we_need
    end

    def initialize_wizard
      if request.get? || request.head?
        wizard.changing_answer(params["changing_answer"] == "1")
        wizard.update_history
      end
    rescue Wizard::AlreadyInitialised, Wizard::InvalidStep
      remove_session_data
      redirect_to abort_path
    end

    def permitted_params
      request.get? || request.head? ? {} : wizard_class.permitted_params_for(step_name)
    end

    def school
      @school ||= policy_scope(School).friendly.find(params[:school_id])
    end

    def step_name
      (params[:step].to_s.underscore.presence || default_step_name).to_sym
    end

    def submitted_params
      @submitted_params ||= params.fetch(wizard_session_key, {}).permit(permitted_params)
    end

    def wizard
      @wizard ||= wizard_class.new(cohort:,
                                   current_step: step_name,
                                   current_user:,
                                   default_step_name:,
                                   school:,
                                   data_store:,
                                   submitted_params:)
    end

    def wizard_session_key
      wizard_class.session_key
    end

    def wizard_back_link_path
      @wizard.previous_step_path
    end

    def remove_session_data
      session.delete(wizard_session_key)
    end

    def save_programme_change
      set_cohort_induction_programme!(@setup_school_cohort_form.programme_choice)
      if previous_school_cohort.full_induction_programme?
        send_fip_programme_changed_email!
      end

      redirect_to action: :what_changes_submitted
    end

    def wizard_class
      Schools::Cohorts::SetupWizard
    end

    def data_store
      @data_store ||= FormData::CohortSetupStore.new(session:, form_key: wizard_class)
    end
  end
end
