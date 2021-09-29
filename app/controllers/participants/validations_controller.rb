# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    before_action :set_form
    before_action :check_not_already_completed, except: :complete
    before_action :validate_request_or_render, only: %i[do_you_want_to_add_mentor_information
                                                        what_is_your_trn
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
        store_form_and_redirect_to_step :do_you_want_to_add_mentor_information
      else
        store_form_and_redirect_to_step :what_is_your_trn
      end
    end

    def do_you_want_to_add_mentor_information
      choice = @participant_validation_form.do_you_want_to_add_mentor_information_choice
      if choice == "yes"
        store_form_and_redirect_to_step :what_is_your_trn
      else
        reset_form_data
        redirect_to helpers.induction_coordinator_dashboard_path(current_user)
      end
    end

    def what_is_your_trn
      store_form_and_redirect_to_step :have_you_changed_your_name
    end

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
      case choice
      when "yes"
        store_form_and_redirect_to_step :tell_us_your_details
      when "no"
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
      store_analytics(matched: false)
      reset_form_data
      store_form_and_redirect_to_step :complete
    end

    def complete
      @school = participant_profile.school
      if participant_profile.ecf_participant_eligibility&.eligible_status? ||
          participant_profile.ecf_participant_eligibility&.matched_status?
        # Probably successful - show success message.
        # Will become: TRN has been validated, qts, no flags, not done before, no previous induction
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
      participant_profile.completed_validation_wizard?
    end

    def validate_participant_details_and_redirect
      result = ValidateParticipant.call(participant_profile: participant_profile,
                                        validation_data: participant_details,
                                        config: { check_first_name_only: true, save_validation_data_without_match: false })

      if result
        store_analytics(matched: true)
        reset_form_data
        store_form_and_redirect_to_step :complete
      else
        store_analytics(matched: false)
        @participant_validation_form.increment_validation_attempts
        store_form_and_redirect_to_step :cannot_find_details
      end
    rescue StandardError => e
      Rails.logger.error("Problem with ValidateParticipant: #{e.message}")
      store_analytics(matched: false)
      reset_form_data
      store_form_and_redirect_to_step :complete
    end

    def participant_details
      @participant_details ||= @participant_validation_form.attributes.slice(:trn, :name, :date_of_birth, :national_insurance_number)
    end

    def store_validation_data!
      participant_profile.create_ecf_participant_validation_data!({
        trn: participant_details[:trn],
        full_name: participant_details[:name],
        date_of_birth: participant_details[:date_of_birth],
        nino: participant_details[:national_insurance_number],
      })
    end

    def participant_profile
      @participant_profile ||= current_user.participant_profiles.active_record.ecf.first
    end

    def set_form
      @participant_validation_form = ParticipantValidationForm.new(session[:participant_validation])
      @participant_validation_form.assign_attributes(form_params)

      if @participant_validation_form.step != action_name
        @participant_validation_form.step = action_name.to_sym
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
      if request.put?
        step = return_to_step || step
      end

      @participant_validation_form.step = step
      session[:participant_validation] = @participant_validation_form.attributes

      if request.get? && return_to_step.present?
        redirect_to send("participants_validation_#{step}_path", return_to: return_to_step)
      else
        redirect_to send("participants_validation_#{step}_path")
      end
    end

    def store_analytics(matched:)
      Analytics::ECFValidationService.record_validation(
        participant_profile: participant_profile,
        real_time_attempts: [@participant_validation_form.validation_attempts, 1].max,
        real_time_success: matched,
        nino_entered: @participant_validation_form.national_insurance_number.present?,
      )
    end

    def return_to_step
      return_step = params.fetch(:return_to, "")
      return return_step if return_step == "confirm_details"
    end

    def form_params
      params.fetch(:participants_participant_validation_form, {}).permit(
        :do_you_want_to_add_mentor_information_choice,
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
