# frozen_string_literal: true

module Schools
  class SetupSchoolCohortController < ::Schools::BaseController
    before_action :load_form
    before_action :school
    before_action :cohort
    before_action :previous_cohort, only: %i[what_changes what_changes_confirmation]
    before_action :lead_provider_name, only: %i[what_changes what_changes_confirmation what_changes_submitted]
    before_action :delivery_partner_name, only: %i[what_changes what_changes_confirmation what_changes_submitted]
    before_action :validate_request_or_render, except: %i[training_confirmation no_expected_ects]

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def expect_any_ects
      if no_ects_expected
        store_form_redirect_to_next_step :no_expected_ects
      elsif ects_expected
        if @school.partnerships.active.find_by(cohort: previous_school_cohort.cohort) && previous_school_cohort&.full_induction_programme?
          store_form_redirect_to_next_step(:change_provider)
        else
          store_form_redirect_to_next_step :how_will_you_run_training
        end
      end
    end

    def no_expected_ects
      set_cohort_induction_programme!("no_early_career_teachers", opt_out_of_updates: true)

      reset_form_data
    end

    # cip
    def how_will_you_run_training
      store_form_redirect_to_next_step :programme_confirmation
    end

    def programme_confirmation
      start_appropriate_body_selection :programme_confirmation, :training_confirmation, :save_training_choice
    end

    def training_confirmation
      reset_form_data
    end

    def change_provider
      case setup_school_cohort_form_params[:change_provider_choice]
      when "yes"
        store_form_redirect_to_next_step :what_changes
      when "no"
        start_appropriate_body_selection :change_provider, :complete, :save_provider_change
      end
    end

    def what_changes
      store_form_redirect_to_next_step :what_changes_confirmation
    end

    def what_changes_confirmation
      start_appropriate_body_selection :what_changes_confirmation, :what_changes_submitted, :save_programme_change
    end

    def what_changes_submitted; end

    def change_fip_programme_choice; end

    def are_you_sure; end

    def complete; end

    def appropriate_body_appointed
      if appropriate_body_appointed?
        store_form_redirect_to_next_step :appropriate_body_type
      else
        end_appropriate_body_selection
      end
    end

    def appropriate_body_type
      store_form_redirect_to_next_step :appropriate_body
    end

    def appropriate_body
      end_appropriate_body_selection
    end

  private

    def save_programme_change
      set_cohort_induction_programme!(@setup_school_cohort_form.programme_choice)

      if previous_school_cohort.full_induction_programme?
        send_fip_programme_changed_email!
      end

      reset_form_data
    end

    def save_provider_change
      # skip if there is already a programme selected for the school cohort
      if active_partnership?
        save_appropriate_body
      else
        use_the_same_training_programme!
        reset_form_data
      end
    end

    def save_training_choice
      set_cohort_induction_programme!(@setup_school_cohort_form.how_will_you_run_training_choice)
      reset_form_data
    end

    def send_fip_programme_changed_email!
      previous_partnership = previous_school_cohort.default_induction_programme.partnership

      previous_partnership.lead_provider.users.each do |lead_provider_user|
        LeadProviderMailer.programme_changed_email(
          partnership: previous_partnership,
          user: lead_provider_user,
          cohort_year: school_cohort.academic_year,
          what_changes_choice: @setup_school_cohort_form.what_changes_choice,
        ).deliver_later
      end
    end

    def ects_expected
      setup_school_cohort_form_params[:expect_any_ects_choice] == "yes"
    end

    def no_ects_expected
      setup_school_cohort_form_params[:expect_any_ects_choice] == "no"
    end

    def previous_school_cohort
      @previous_school_cohort ||= @school.school_cohorts.previous
    end

    def use_the_same_training_programme!
      # Copy the previous active partnership for the new cohort
      # with challenge date set to 31st Oct 2022
      #
      # TODO: we need a better way to set the challenge date
      # previous_partnership_copy = @school.active_partnerships.find_by(cohort: previous_cohort, relationship: false).dup
      # previous_partnership_copy.cohort = cohort
      # previous_partnership_copy.challenge_deadline = Date.new(2022, 10, 31)
      # previous_partnership_copy.save!

      set_cohort_induction_programme!("full_induction_programme")
    end

    def active_partnership?
      @school.active_partnerships.find_by(cohort:, relationship: false).present?
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
                    :change_provider_choice,
                    :what_changes_choice,
                    :appropriate_body_appointed,
                    :appropriate_body_type,
                    :appropriate_body)
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

    def set_cohort_induction_programme!(programme_choice, opt_out_of_updates: false)
      # Induction::SetCohortInductionProgramme.call(school_cohort:,
      #                                             programme_choice:,
      #                                             opt_out_of_updates:,
      #                                             delivery_partner_to_be_confirmed: delivery_partner_to_be_confirmed?,
      #                                             appropriate_body_appointed: appropriate_body_appointed?,
      #                                             appropriate_body: @setup_school_cohort_form.appropriate_body)
    end

    def appropriate_body_appointed?
      @setup_school_cohort_form.appropriate_body_appointed == "yes"
    end

    def save_appropriate_body
      Induction::SetSchoolCohortAppropriateBody.call(school_cohort:,
                                                     appropriate_body_id: @setup_school_cohort_form.appropriate_body,
                                                     appropriate_body_appointed: appropriate_body_appointed?)
    end

    def school_cohort
      @school_cohort ||= school.school_cohorts.find_or_initialize_by(cohort:)
    end

    def cohort
      @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
    end

    def previous_cohort
      @previous_cohort ||= previous_school_cohort&.cohort
    end

    def lead_provider_name
      @lead_provider_name ||= school.lead_provider(previous_cohort.start_year)&.name
    end

    def delivery_partner_name
      @delivery_partner_name ||= school.delivery_partner_for(previous_cohort.start_year)&.name
    end

    def delivery_partner_to_be_confirmed?
      @setup_school_cohort_form.what_changes_choice == "change_delivery_partner"
    end

    def start_appropriate_body_selection(from_action, to_action, on_save)
      @setup_school_cohort_form.appropriate_body_from_action = from_action
      @setup_school_cohort_form.appropriate_body_to_action = to_action
      @setup_school_cohort_form.on_save = on_save
      store_form_redirect_to_next_step :appropriate_body_appointed
    end

    def end_appropriate_body_selection
      on_save = method(@setup_school_cohort_form.on_save)
      on_save.call
      redirect_to action: @setup_school_cohort_form.appropriate_body_to_action
    end
  end
end
