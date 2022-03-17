# frozen_string_literal: true

module Schools
  class TransferringParticipantsController < ::Schools::BaseController
    before_action :load_joining_participant_form, except: %i[what_we_need]
    before_action :load_participants_induction_record, only: %i[email choose_mentor schools_current_programme choose_delivery_partner check_answers]
    before_action :set_school_cohort
    before_action :validate_request_or_render, except: %i[what_we_need]

    skip_after_action :verify_authorized

    def what_we_need
      reset_form_data
    end

    def full_name
      if check_against_dqt?
        if valid_participant_details?
          store_form_redirect_to_next_step(:teacher_start_date)
        else
          store_form_redirect_to_next_step(:cannot_find_details)
        end
      else
        store_form_redirect_to_next_step(:trn)
      end
    end

    def trn
      if check_against_dqt?
        if valid_participant_details?
          store_form_redirect_to_next_step(:teacher_start_date)
        else
          store_form_redirect_to_next_step(:cannot_find_details)
        end
      else
        store_form_redirect_to_next_step(:dob)
      end
    end

    def dob
      if check_against_dqt? && valid_participant_details?
        store_form_redirect_to_next_step(:teacher_start_date)
      else
        store_form_redirect_to_next_step(:cannot_find_their_details)
      end
    end

    def teacher_start_date
      store_form_redirect_to_next_step(:email)
    end

    def email
      if @latest_induction_record.participant_profile.ect?
        store_form_redirect_to_next_step(:choose_mentor)
      elsif with_the_same_provider?
        store_form_redirect_to_next_step(:schools_current_programme)
      else
        store_form_redirect_to_next_step(:teachers_current_programme)
      end
    end

    def choose_mentor
      if with_the_same_provider?
        store_form_redirect_to_next_step(:schools_current_programme)
      else
        store_form_redirect_to_next_step(:teachers_current_programme)
      end
    end

    def teachers_current_programme
      case @transferring_participant_form.teachers_current_programme_choice
      when "no"
        store_form_redirect_to_next_step(:schools_current_programme)
      when "yes"
        store_form_redirect_to_next_step(:check_answers)
      else
        store_form_redirect_to_next_step(:cannot_add)
      end
    end

    def schools_current_programme
      schools_programme_choice = @transferring_participant_form.schools_current_programme_choice

      if schools_programme_choice == "yes" && matching_lead_provider_and_delivery_partner?
        @transferring_participant_form.same_programme = true
        store_form_redirect_to_next_step(:check_answers)
      elsif schools_programme_choice == "yes" && with_the_same_provider?
        store_form_redirect_to_next_step(:choose_delivery_partner)
      elsif schools_programme_choice == "yes" && @transferring_participant_form.teachers_current_programme_choice == "no"
        @transferring_participant_form.same_programme = true
        store_form_redirect_to_next_step(:choose_delivery_partner)
      else
        store_form_redirect_to_next_step(:cannot_add)
      end
    end

    def choose_delivery_partner
      schools_programme_choice = @transferring_participant_form.delivery_partner_choice
      if schools_programme_choice == "school"
        @transferring_participant_form.same_programme = true
      end
      store_form_redirect_to_next_step(:check_answers)
    end

    def check_answers
      # Finish enroll process
      if @transferring_participant_form.schools_current_programme_choice == "yes"
        Induction::Enrol.call(
          participant_profile: @latest_induction_record.participant_profile,
          induction_programme: @school_cohort.default_induction_programme,
          start_date: @transferring_participant_form.start_date,
          registered_identity: @latest_induction_record.participant_profile.participant_identity,
        )
      end
      store_form_redirect_to_next_step(:complete)
    end

    def contact_support
      reset_form_data
    end

    def complete; end

    def cannot_find_their_details; end

    def cannot_add; end

  private

    def load_joining_participant_form
      @transferring_participant_form = TransferringParticipantForm.new(session[:schools_transferring_participant_form])
      @transferring_participant_form.assign_attributes(transferring_participant_form_params)
    end

    def transferring_participant_form_params
      return {} unless params.key?(:schools_transferring_participant_form)

      params.require(:schools_transferring_participant_form)
            .permit(:full_name,
                    :trn, :date_of_birth,
                    :start_date,
                    :email,
                    :mentor_id,
                    :schools_current_programme_choice,
                    :teachers_current_programme_choice,
                    :delivery_partner_choice)
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

    def load_participants_induction_record
      validation_record = ECFParticipantValidationData.find_by(
        "LOWER(full_name) = ? AND trn = ? AND date_of_birth = ?",
        @transferring_participant_form.full_name.downcase,
        @transferring_participant_form.trn,
        @transferring_participant_form.date_of_birth,
      )
      @latest_induction_record = InductionRecord.find_by(participant_profile: validation_record.participant_profile)
    end

    def valid_participant_details?
      TransferringParticipantEligibilityCheck.new(@transferring_participant_form).call
    end

    def matching_lead_provider_and_delivery_partner?
      with_the_same_provider? && with_the_same_delivery_partner?
    end

    def with_the_same_provider?
      @school_cohort.default_induction_programme&.lead_provider == @latest_induction_record.induction_programme&.lead_provider
    end

    def with_the_same_delivery_partner?
      @school_cohort.default_induction_programme&.delivery_partner == @latest_induction_record.induction_programme&.delivery_partner
    end

    def check_against_dqt?
      @transferring_participant_form.full_name.present? &&
        @transferring_participant_form.trn.present? &&
        @transferring_participant_form.date_of_birth.present?
    end

    def reset_form_data
      session.delete(:schools_transferring_participant_form)
    end
  end
end
