# frozen_string_literal: true

module Schools
  class SetupSchoolCohortController < ::Schools::BaseController
    before_action :load_form
    before_action :latest_induction_record, only: %i[email choose_mentor teachers_current_programme schools_current_programme check_answers complete]
    before_action :school
    before_action :validate_request_or_render, except: %i[what_we_need]

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def expect_any_ects
      previous_cohort = @school.school_cohorts.find_by(cohort: Cohort.find_by(start_year: Cohort.active_registration_cohort.start_year - 1))

      if previous_cohort.full_induction_programme?
        store_form_redirect_to_next_step(:change_provider)
      elsif previous_cohort.core_induction_programme?
      end
    end

    # cip
    def how_will_you_run_training; end

    def change_provider; end

    def change_fip_programme_choice; end

    def are_you_sure; end

    def complete; end

  private

    def load_form
      @setup_school_cohort_form = SetupSchoolCohortForm.new(session[:setup_school_cohort_form])
      @setup_school_cohort_form.assign_attributes(setup_school_cohort_form_params)
    end

    def setup_school_cohort_form_params
      return {} unless params.key?(:schools_setup_school_cohort_form)

      params.require(:schools_setup_school_cohort_form)
            .permit(:expect_any_ects_choice,
                    :trn,
                    :date_of_birth,
                    :start_date,
                    :email,
                    :mentor_id,
                    :schools_current_programme_choice,
                    :teachers_current_programme_choice)
    end

    def validate_request_or_render
      render unless request.put? && step_valid?
    end

    def store_form_redirect_to_next_step(step)
      session[:setup_school_cohort_form] = @setup_school_cohort_form.serializable_hash
      redirect_to action: step
    end

    def step_valid?
      @setup_school_cohort_form.valid? action_name.to_sym
    end

    def reset_form_data
      session.delete(:setup_school_cohort_form)
    end

    def school
      @school ||= active_school
    end
  end
end
