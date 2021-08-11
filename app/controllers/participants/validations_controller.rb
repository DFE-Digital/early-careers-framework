# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    before_action :set_form
    before_action :check_not_already_completed, except: :complete
    before_action :validate_request_or_render, only: %i[do_you_know_your_trn
                                                        have_you_changed_your_name
                                                        confirm_updated_record
                                                        name_not_updated
                                                        tell_us_your_details
                                                        confirm_details
                                                        cannot_find_details]

    def start
      # check whether the user is a SIT/mentor and offer the choice
      # to proceed (unless they have already completed)
      if current_user.induction_coordinator?
        store_for_and_redirect_to_step :do_you_want_to_add_mentor_information
      else
        store_form_and_redirect_to_step :do_you_know_your_trn
      end
    end

    def do_you_want_to_add_mentor_information
      choice = @participant_validation_form.do_you_want_to_add_mentor_information_choice
      if choice == "yes"
        store_form_and_redirect_to_step :do_you_know_your_trn
      else
        reset_form_data
        redirect_to induction_coordinator_dashboard_path(current_user)
      end
    end

    def do_you_know_your_trn
      choice = @participant_validation_form.do_you_know_your_trn_choice
      if choice == "yes"
        store_form_and_redirect_to_step :have_you_changed_your_name
      elsif choice == "no"
        store_form_and_redirect_to_step :find_your_trn
      else
        store_form_and_redirect_to_step :get_a_trn
      end
    end

    def find_your_trn; end

    def get_a_trn; end

    def have_you_changed_your_name
      choice = @participant_validation_form.have_you_changed_your_name_choice
      if choice == "yes"
        store_form_and_redirect_to_step :confirm_updated_record
      else
        store_form_and_redirect_to_step :tell_us_your_details
      end
    end

    def confirm_updated_record
      choice = @participant_validation_form.updated_record_choice
      if choice == "yes"
        store_form_and_redirect_to_step :tell_us_your_details
      elsif choice == "no"
        store_form_and_redirect_to_step :name_not_updated
      else
        store_form_and_redirect_to_step :check_with_tra
      end
    end

    def name_not_updated
      choice = @participant_validation_form.name_not_updated_choice
      if choice == "register_previous_name"
        store_form_and_redirect_to_step :tell_us_your_details
      else
        store_form_and_redirect_to_step :change_your_details_with_tra
      end
    end

    def change_your_details_with_tra; end

    def check_with_tra; end

    def tell_us_your_details
      store_form_and_redirect_to_step :confirm_details
    end

    def confirm_details
      validate_participant_details_and_redirect
    end

    def cannot_find_details
      store_validation_data!
      reset_form_data
      store_form_and_redirect_to_step :complete
    end

    def complete
      @school = participant_profile.school
      if participant_profile.ecf_participant_eligibility&.eligible_status?
        # TRN has been validated, qts, no flags, not done before, no previous induction
        render_completed_page
      else
        # all other cases
        render_manual_check_page
      end
    end

  private

    def validate_request_or_render
      render unless request.put? && step_valid?
    end

    def render_completed_page
      if participant_profile.school_cohort.full_induction_programme?
        @partnership = @school.partnerships.active.find_by(cohort: participant_profile.school_cohort.cohort)
        render "complete_fip"
      else
        render "complete_cip"
      end
    end

    def render_manual_check_page
      if participant_profile.school_cohort.full_induction_programme?
        @partnership = @school.partnerships.active.find_by(cohort: participant_profile.school_cohort.cohort)
        render "manual_details_check_fip"
      else
        render "manual_details_check_cip"
      end
    end

    def check_not_already_completed
      store_form_and_redirect_to_step :complete if flow_complete?
    end

    def flow_complete?
      participant_profile.ecf_participant_validation_data.present? || participant_profile.ecf_participant_eligibility.present?
    end

    def validate_participant_details_and_redirect
      result = ParticipantValidationService.validate(trn: participant_details[:trn],
                                                     full_name: participant_details[:name],
                                                     date_of_birth: participant_details[:date_of_birth],
                                                     nino: participant_details[:national_insurance_number])

      if result.nil?
        @participant_validation_form.increment_validation_attempts
        store_form_and_redirect_to_step :cannot_find_details
      else
        eligibility_data = store_eligibility_data!(result)
        eligibility_data.manual_check_status! unless store_trn!(result[:trn])

        # store validation data for manual re-check later
        # if different TRN already exists or not eligible
        store_validation_data! unless eligibility_data.eligible_status?

        reset_form_data
        store_form_and_redirect_to_step :complete
      end
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API: " + e.message)
      store_validation_data!(api_failure: true)
      reset_form_data
      store_form_and_redirect_to_step :complete
    end

    def participant_details
      @participant_details ||= @participant_validation_form.attributes.slice(:trn, :name, :date_of_birth, :national_insurance_number)
    end

    def store_validation_data!(opts = {})
      participant_profile.create_ecf_participant_validation_data!({
        trn: participant_details[:trn],
        full_name: participant_details[:name],
        date_of_birth: participant_details[:date_of_birth],
        nino: participant_details[:national_insurance_number],
      }.merge(opts))
    end

    def store_trn!(trn)
      if participant_profile.teacher_profile.trn.present? && participant_profile.teacher_profile.trn != trn
        Rails.logger.warn("Different TRN already set for user [#{current_user.email}]")
        false
      else
        participant_profile.teacher_profile.update!(trn: trn)
      end
    end

    def store_eligibility_data!(dqt_data)
      participant_profile.create_ecf_participant_eligibility!(qts: dqt_data[:qts],
                                                              active_flags: dqt_data[:active_alert],
                                                              previous_participation: nil,
                                                              previous_induction: nil)
    end

    def participant_profile
      @participant_profile ||= current_user.participant_profiles.active.ecf.first
    end

    def set_form
      @participant_validation_form = ParticipantValidationForm.new(session[:participant_validation])
      @participant_validation_form.assign_attributes(form_params)

      if @participant_validation_form.step.blank?
        @participant_validation_form.step = :start
      elsif @participant_validation_form.step != action_name
        store_form_and_redirect_to_step action_name
      end
    end

    def reset_form_data
      session.delete(:participant_validation)
    end

    def step_valid?
      @participant_validation_form.valid?(@participant_validation_form.step.to_sym)
    end

    def store_form_and_redirect_to_step(step)
      @participant_validation_form.step = step
      session[:participant_validation] = @participant_validation_form.attributes
      redirect_to send("participants_validation_#{step}_path")
    end

    def form_params
      params.fetch(:participants_participant_validation_form, {}).permit(
        :do_you_know_your_trn_choice,
        :have_you_changed_your_name_choice,
        :updated_record_choice,
        :name_not_updated_choice,
        :trn,
        :name,
        :date_of_birth,
        :national_insurance_number,
        :step,
      )
    end
  end
end
