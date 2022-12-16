# frozen_string_literal: true

module Schools
  class TransferringParticipantsController < ::Schools::BaseController
    before_action :load_joining_participant_form, except: %i[what_we_need]
    before_action :set_current_steps, except: %i[what_we_need]
    before_action :set_school_cohort_vars
    before_action :check_school_cohort, except: %i[need_training_setup]
    before_action :existing_induction_record, only: %i[teacher_start_date email choose_mentor teachers_current_programme schools_current_programme check_answers complete]
    before_action :already_enrolled_at_school?, only: %i[teacher_start_date email choose_mentor teachers_current_programme schools_current_programme check_answers]
    before_action :validate_request_or_render, except: %i[what_we_need]

    skip_after_action :verify_authorized

    def check_transfer; end

    def what_we_need
      reset_form_data
    end

    def full_name
      validate_or_next_step(valid_step: :teacher_start_date, next_step: :trn)
    end

    def trn
      validate_or_next_step(valid_step: :teacher_start_date, next_step: :dob)
    end

    def dob
      validate_or_next_step(valid_step: :teacher_start_date, next_step: :cannot_find_their_details)
    end

    def need_training_setup
      if participant_cohort == Cohort.active_registration_cohort
        redirect_to expect_any_ects_schools_setup_school_cohort_path(cohort_id: participant_cohort)
      else
        redirect_to schools_choose_programme_path(cohort_id: participant_cohort)
      end
      reset_form_data
    end

    def teacher_start_date
      check_start_date_is_later_than_induction_start
      store_form_redirect_to_next_step(:email) unless @transferring_participant_form.errors.any?
    end

    def email
      if show_mentor?
        store_form_redirect_to_next_step(:choose_mentor)
      elsif matching_lead_provider_and_delivery_partner?
        @transferring_participant_form.same_programme = true
        store_form_redirect_to_next_step(:check_answers)
      else
        store_form_redirect_to_next_step(:teachers_current_programme)
      end
    end

    def choose_mentor
      if withdrawn_participant?
        store_form_redirect_to_next_step(:check_answers)
      elsif matching_lead_provider_and_delivery_partner?
        @transferring_participant_form.same_programme = true
        store_form_redirect_to_next_step(:check_answers)
      else
        store_form_redirect_to_next_step(:teachers_current_programme)
      end
    end

    def teachers_current_programme
      if @transferring_participant_form.continue_teachers_programme?
        store_form_redirect_to_next_step(:check_answers)
      else
        store_form_redirect_to_next_step(:schools_current_programme)
      end
    end

    def schools_current_programme
      if @transferring_participant_form.switch_to_schools_programme?
        store_form_redirect_to_next_step(:check_answers)
      else
        store_form_redirect_to_next_step(:cannot_add)
      end
    end

    def check_answers
      was_withdrawn_participant = withdrawn_participant?

      # Finish enroll process and send notification emails
      new_induction_record = if matching_lead_provider_and_delivery_partner? || withdrawn_participant?
                               transfer_fip_participant_to_schools_programme
                             elsif @transferring_participant_form.switch_to_schools_programme?
                               transfer_fip_participant_to_schools_programme
                             else
                               transfer_fip_participant_and_continue_existing_programme
                             end
      send_notification_emails!(new_induction_record, was_withdrawn_participant)
      store_form_redirect_to_next_step(:complete)
    end

    def contact_support
      reset_form_data
    end

    def complete; end

    def cannot_find_their_details; end

    def cannot_add; end

    helper_method :with_same_provider_and_different_delivery_partner?, :show_mentor?
    helper_method :lead_provider_in, :lead_provider_out, :delivery_partner_in, :delivery_partner_out

  private

    def already_enrolled_at_school?
      render :already_enrolled_at_school and return if existing_induction_record.school == @school_cohort.school
    end

    def check_against_dqt?
      @transferring_participant_form.full_name.present? &&
        @transferring_participant_form.formatted_trn.present? &&
        @transferring_participant_form.date_of_birth.present?
    end

    def check_start_date_is_later_than_induction_start
      start_date = @transferring_participant_form.start_date
      previous_date = existing_induction_record.schedule.milestones.first.start_date
      if start_date < previous_date
        @transferring_participant_form.errors.add(:start_date, I18n.t("errors.start_date.before_schedule_start_date", date: previous_date.to_date.to_s(:govuk)))
      end
    end

    def delivery_partner_in
      @delivery_partner_in ||= @school_cohort.default_induction_programme&.delivery_partner
    end

    def delivery_partner_out
      @delivery_partner_out ||= existing_induction_record.delivery_partner
    end

    def dqt_record
      ParticipantValidationService.validate(
        full_name: @transferring_participant_form.full_name,
        trn: @transferring_participant_form.formatted_trn,
        date_of_birth: @transferring_participant_form.date_of_birth,
        nino: nil,
        config: {
          check_first_name_only: true,
        },
      )
    end

    def existing_induction_record
      @existing_induction_record ||= participant_profile.latest_induction_record
    end

    def lead_provider_in
      @lead_provider_in ||= @school_cohort.default_induction_programme&.lead_provider
    end

    def lead_provider_out
      @lead_provider_out ||= existing_induction_record.lead_provider
    end

    def load_joining_participant_form
      @transferring_participant_form = TransferringParticipantForm.new(session[:schools_transferring_participant_form])
      @transferring_participant_form.assign_attributes(transferring_participant_form_params)
    end

    def matching_lead_provider_and_delivery_partner?
      with_the_same_provider? && with_the_same_delivery_partner?
    end

    def participant_profile
      @participant_profile ||= @transferring_participant_form&.participant_profile
    end

    def participant_cohort
      @participant_cohort ||= participant_profile.schedule.cohort
    end

    def reset_form_data
      session.delete(:schools_transferring_participant_form)
    end

    # This methods assumes that all transfers are requested by the incoming school for now. There
    # are three paths here:
    #
    # 1) Moving schools but lead provider is same at both schools:
    #
    #   a. Send email to existing lead provider notifying them that an internal
    #      transfer is happening.
    #   b. Send email to participant to notify them.
    #
    # 2) Moving to target schools lead provider and programme:
    #
    #   a. Send email to incoming lead provider.
    #   b. Send email to outgoing lead provider, requesting that they withdraw them.
    #   c. Send email to participant to notify them.
    #
    # 3) Moving to target school, but continuing with current lead provider.
    #
    #   a. Send email to current lead provider, notifying them to expect a new school.
    #   b. Send email to participant to notify them.
    #
    def send_notification_emails!(new_induction_record, was_withdrawn_participant)
      lead_provider_profiles_in = lead_provider_in&.users&.map(&:lead_provider_profile) || []
      lead_provider_profiles_out = lead_provider_out&.users&.map(&:lead_provider_profile) || []

      Induction::SendTransferNotificationEmails.call(
        induction_record: new_induction_record,
        was_withdrawn_participant:,
        same_delivery_partner: with_the_same_delivery_partner?,
        same_provider: with_the_same_provider?,
        switch_to_schools_programme: @transferring_participant_form.switch_to_schools_programme?,
        lead_provider_profiles_in:,
        lead_provider_profiles_out:,
      )
    end

    def check_school_cohort
      if participant_profile && participant_cohort != active_cohort
        @school_cohort = @school.school_cohorts.find_by(cohort: participant_cohort)
        if @school_cohort.present? && @school_cohort.full_induction_programme?
          set_school_cohort(cohort: participant_cohort)
        else
          store_form_redirect_to_next_step(:need_training_setup)
        end
      end
    end

    def set_school_cohort_vars
      @cohort = active_cohort
      @school = active_school
      @school_cohort = policy_scope(SchoolCohort).find_by(cohort: @cohort, school: @school)
    end

    def set_current_steps
      @transferring_participant_form.current_step = action_name
      @transferring_participant_form.update_steps
    end

    def step_valid?
      @transferring_participant_form.valid? action_name.to_sym
    end

    def store_form_redirect_to_next_step(step)
      session[:schools_transferring_participant_form] = @transferring_participant_form.serializable_hash
      redirect_to action: step
    end

    def show_mentor?
      if FeatureFlag.active?(:multiple_cohorts)
        participant_profile.ect? && @school_cohort.school.school_mentors.any?
      else
        participant_profile.ect? && @school_cohort.active_mentors.any?
      end
    end

    def transfer_fip_participant_to_schools_programme
      Induction::TransferToSchoolsProgramme.call(
        participant_profile:,
        induction_programme: @school_cohort.default_induction_programme,
        start_date: @transferring_participant_form.start_date,
        email: @transferring_participant_form.email,
        mentor_profile: @transferring_participant_form.mentor_profile,
      )
    end

    def transfer_fip_participant_and_continue_existing_programme
      Induction::TransferAndContinueExistingFip.call(
        school_cohort: @school_cohort,
        participant_profile:,
        email: @transferring_participant_form.email,
        start_date: @transferring_participant_form.start_date,
        end_date: @transferring_participant_form.start_date,
        mentor_profile: @transferring_participant_form.mentor_profile,
      )
    end

    def transferring_participant_form_params
      return {} unless params.key?(:schools_transferring_participant_form)

      params.require(:schools_transferring_participant_form)
            .permit(:full_name,
                    :trn,
                    :date_of_birth,
                    :start_date,
                    :email,
                    :mentor_id,
                    :schools_current_programme_choice,
                    :teachers_current_programme_choice)
    end

    def validate_or_next_step(valid_step:, next_step:)
      if check_against_dqt?
        if valid_participant_details?
          store_form_redirect_to_next_step(valid_step)
        else
          store_form_redirect_to_next_step(:cannot_find_their_details)
        end
      else
        store_form_redirect_to_next_step(next_step)
      end
    end

    def validate_request_or_render
      render unless request.put? && step_valid?
    end

    def valid_participant_details?
      participant_profile.present? && dqt_record.present?
    end

    def withdrawn_participant?
      participant_profile.training_status_withdrawn? || existing_induction_record.training_status_withdrawn?
    end

    def with_same_provider_and_different_delivery_partner?
      with_the_same_provider? && !with_the_same_delivery_partner?
    end

    def with_the_same_provider?
      lead_provider_in == lead_provider_out
    end

    def with_the_same_delivery_partner?
      delivery_partner_in == delivery_partner_out
    end
  end
end
