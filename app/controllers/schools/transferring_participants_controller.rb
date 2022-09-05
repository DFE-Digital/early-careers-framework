# frozen_string_literal: true

module Schools
  class TransferringParticipantsController < ::Schools::BaseController
    before_action :load_joining_participant_form, except: %i[what_we_need]
    before_action :set_current_steps, except: %i[what_we_need]
    before_action :set_school_cohort
    before_action :latest_induction_record, only: %i[teacher_start_date email choose_mentor teachers_current_programme schools_current_programme check_answers complete]
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
      induction_record = if matching_lead_provider_and_delivery_partner? || withdrawn_participant?
                           transfer_fip_participant_to_schools_programme
                         elsif @transferring_participant_form.switch_to_schools_programme?
                           transfer_fip_participant_to_schools_programme
                         else
                           transfer_fip_participant_and_continue_existing_programme
                         end

      send_notification_emails!(induction_record, was_withdrawn_participant)
      store_form_redirect_to_next_step(:complete)
    end

    def contact_support
      reset_form_data
    end

    def complete; end

    def cannot_find_their_details; end

    def cannot_add; end

    helper_method :with_same_provider_and_different_delivery_partner?, :show_mentor?

  private

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
    def send_notification_emails!(induction_record, was_withdrawn_participant)
      current_lead_provider_profiles = current_lead_provider&.users&.map(&:lead_provider_profile) || []
      target_lead_provider_profiles = participant_lead_provider&.users&.map(&:lead_provider_profile) || []

      Induction::SendTransferNotificationEmails.call(
        induction_record:,
        was_withdrawn_participant:,
        same_delivery_partner: with_the_same_delivery_partner?,
        same_provider: with_the_same_provider?,
        switch_to_schools_programme: @transferring_participant_form.switch_to_schools_programme?,
        current_lead_provider_profiles:,
        target_lead_provider_profiles:,
      )
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

    def load_joining_participant_form
      @transferring_participant_form = TransferringParticipantForm.new(session[:schools_transferring_participant_form])
      @transferring_participant_form.assign_attributes(transferring_participant_form_params)
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

    def validate_request_or_render
      render unless request.put? && step_valid?
    end

    def store_form_redirect_to_next_step(step)
      session[:schools_transferring_participant_form] = @transferring_participant_form.serializable_hash
      redirect_to action: step
    end

    def step_valid?
      @transferring_participant_form.valid? action_name.to_sym
    end

    def latest_induction_record
      @latest_induction_record ||= participant_profile.induction_records.latest
    end

    def valid_participant_details?
      participant_profile.present? && dqt_record.present?
    end

    def withdrawn_participant?
      participant_profile.training_status_withdrawn? || latest_induction_record.training_status_withdrawn?
    end

    def matching_lead_provider_and_delivery_partner?
      with_the_same_provider? && with_the_same_delivery_partner?
    end

    def current_lead_provider
      @school_cohort.default_induction_programme&.lead_provider
    end

    def current_delivery_partner
      @school_cohort.default_induction_programme&.delivery_partner
    end

    def with_same_provider_and_different_delivery_partner?
      with_the_same_provider? && !with_the_same_delivery_partner?
    end

    def show_mentor?
      if FeatureFlag.active?(:multiple_cohorts)
        @latest_induction_record.participant_profile.ect? && @school_cohort.school.school_mentors.any?
      else
        @latest_induction_record.participant_profile.ect? && @school_cohort.active_mentors.any?
      end
    end

    # Target lead provider
    def participant_lead_provider
      latest_induction_record.induction_programme&.lead_provider
    end

    # Target delivery partner
    def participant_delivery_partner
      latest_induction_record.induction_programme&.delivery_partner
    end

    def with_the_same_provider?
      current_lead_provider == participant_lead_provider
    end

    def with_the_same_delivery_partner?
      current_delivery_partner == participant_delivery_partner
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

    def check_against_dqt?
      @transferring_participant_form.full_name.present? &&
        @transferring_participant_form.formatted_trn.present? &&
        @transferring_participant_form.date_of_birth.present?
    end

    def already_enrolled_at_school?
      render :already_enrolled_at_school and return if @latest_induction_record.school == @school_cohort.school
    end

    def participant_profile
      first_name = @transferring_participant_form.full_name.split(" ").first

      @participant_profile ||= ParticipantProfile::ECF.joins(:ecf_participant_validation_data)
          .where("full_name ILIKE ? AND trn = ? AND date_of_birth = ?",
                 "#{first_name} %",
                 @transferring_participant_form.formatted_trn,
                 @transferring_participant_form.date_of_birth).first
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

    def check_start_date_is_later_than_induction_start
      start_date = @transferring_participant_form.start_date
      previous_date = participant_profile.induction_records.latest.schedule.milestones.first.start_date
      if start_date < previous_date
        @transferring_participant_form.errors.add(:start_date, I18n.t("errors.start_date.before_schedule_start_date", date: previous_date.to_date.to_s(:govuk)))
      end
    end

    def reset_form_data
      session.delete(:schools_transferring_participant_form)
    end

    def set_current_steps
      @transferring_participant_form.current_step = action_name
      @transferring_participant_form.update_steps
    end
  end
end
