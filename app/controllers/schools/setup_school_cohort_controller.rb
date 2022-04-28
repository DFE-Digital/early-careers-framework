# frozen_string_literal: true

module Schools
  class SetupSchoolCohortController < ::Schools::BaseController
    before_action :load_form
    before_action :school
    before_action :validate_request_or_render, except: %i[training_confirmation no_expected_ects]

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def expect_any_ects
      previous_cohort = @school.school_cohorts.previous

      if previous_cohort.full_induction_programme?
        # FIP
        store_form_redirect_to_next_step(:change_provider)
      elsif previous_cohort.core_induction_programme?
        # DIY CIP
        if no_ects_expected
          store_form_redirect_to_next_step :no_expected_ects
        elsif ects_expected
          store_form_redirect_to_next_step :how_will_you_run_training
        end
      end
    end

    def no_expected_ects
      unless school_cohort.persisted?
        school_cohort.induction_programme_choice = :no_early_career_teachers
        school_cohort.save!
      end

      reset_form_data
    end

    # cip
    def how_will_you_run_training
      store_form_redirect_to_next_step :programme_confirmation
    end

    def programme_confirmation; end

    def training_confirmation
      reset_form_data
    end

    def change_provider
      case setup_school_cohort_form_params[:change_provider_choice]
      when "yes"
        store_form_redirect_to_next_step :what_change
      when "no"
        store_form_redirect_to_next_step :fip_confirmation
      end
    end

    def change_fip_programme_choice; end

    def are_you_sure; end

    def complete; end

    def save_programme
      save_school_choice!

      redirect_to training_confirmation_schools_setup_school_cohort_path
    end

  private

    def ects_expected
      setup_school_cohort_form_params[:expect_any_ects_choice] == "yes"
    end

    def no_ects_expected
      setup_school_cohort_form_params[:expect_any_ects_choice] == "no"
    end

    def load_form
      @setup_school_cohort_form = SetupSchoolCohortForm.new(session[:setup_school_cohort_form])
      @setup_school_cohort_form.assign_attributes(setup_school_cohort_form_params)
    end

    def setup_school_cohort_form_params
      return {} unless params.key?(:schools_setup_school_cohort_form)

      params.require(:schools_setup_school_cohort_form)
            .permit(:expect_any_ects_choice,
                    :how_will_you_run_training_choice,
                    :trn,
                    :date_of_birth,
                    :start_date,
                    :email,
                    :mentor_id,
                    :schools_current_programme_choice,
                    :teachers_current_programme_choice,
                    :change_provider_choice)
    end

    def validate_request_or_render
      render unless (request.post? || request.put?) && step_valid?
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

    def save_school_choice!
      Induction::SetCohortInductionProgramme.call(school_cohort: school_cohort,
                                                  programme_choice: @setup_school_cohort_form.attributes[:how_will_you_run_training_choice])
    end

    def school_cohort
      @school_cohort ||= school.school_cohorts.find_or_initialize_by(cohort: cohort)
    end

    def cohort
      @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
    end
  end
end
