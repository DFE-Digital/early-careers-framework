# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    skip_before_action :ensure_participant, only: :reset
    before_action :set_form
    before_action :check_not_already_completed, except: %i[complete reset]

    def start
      redirect_to_step :do_you_know_your_trn
    end

    def do_you_know_your_trn
      if request.put?
        if step_valid?
          choice = @form.do_you_know_your_trn_choice
          if choice == "yes"
            redirect_to_step :have_you_changed_your_name
          elsif choice == "no"
            redirect_to_step :find_your_trn
          else
            redirect_to_step :get_a_trn
          end
        end
      end
    end

    def find_your_trn; end

    def get_a_trn; end

    def have_you_changed_your_name
      if request.put?
        if step_valid?
          choice = @form.have_you_changed_your_name_choice
          if choice == "yes"
            redirect_to_step :confirm_updated_record
          else
            redirect_to_step :tell_us_your_details
          end
        end
      end
    end

    def confirm_updated_record
      if request.put?
        if step_valid?
          choice = @form.updated_record_choice
          if choice == "yes"
            redirect_to_step :tell_us_your_details
          elsif choice == "no"
            redirect_to_step :name_not_updated
          else
            redirect_to_step :check_with_tra
          end
        end
      end
    end

    def name_not_updated
      if request.put?
        if step_valid?
          choice = @form.name_not_updated_choice
          if choice == "register_previous_name"
            redirect_to_step :tell_us_your_details
          else
            redirect_to_step :change_your_details_with_tra
          end
        end
      end
    end

    def change_your_details_with_tra; end

    def check_with_tra; end

    def tell_us_your_details
      if request.put?
        if step_valid?
          redirect_to_step :confirm_details
        end
      end
    end

    def confirm_details
      if request.put?
        if step_valid?
          validate_participant_details_and_redirect
        end
      end
    end

    def cannot_find_details
      if request.put?
        if step_valid?
          store_validation_data!
          reset_form_data
          redirect_to_step :complete
        end
      end
    end

    def complete
      @school = participant.school
      if participant.ecf_participant_eligibility.present? && participant.ecf_participant_eligibility.eligible_status?
        # TRN has been validated, qts, no flags, not done before, no previous induction
        render_completed_page
      else
        # all other cases
        render_manual_check_page
      end
    end

    def reset
      reset_form_data
      redirect_to participants_validation_start_path
    end

  private

    def render_completed_page
      if participant.school_cohort.full_induction_programme?
        @partnership = @school.partnerships.active.find_by(cohort: participant.school_cohort.cohort)
        render "complete_fip"
      else
        render "complete_cip"
      end
    end

    def render_manual_check_page
      if participant.school_cohort.full_induction_programme?
        @partnership = @school.partnerships.active.find_by(cohort: participant.school_cohort.cohort)
        render "manual_details_check_fip"
      else
        render "manual_details_check_cip"
      end
    end

    def check_not_already_completed
      redirect_to_step :complete if complete?
    end

    def complete?
      participant.ecf_participant_validation_data.present? || participant.ecf_participant_eligibility.present?
    end

    def validate_participant_details_and_redirect
      result = ParticipantValidationService.validate(trn: @form.trn,
                                                     full_name: @form.name,
                                                     date_of_birth: @form.date_of_birth,
                                                     nino: @form.national_insurance_number)
      if result.nil?
        @form.increment_validation_attempts
        redirect_to_step :cannot_find_details
      else
        store_trn!(result[:trn])
        eligibility_data = store_eligibility_data!(result)
        # if not eligibile store validation data for re-check later
        store_validation_data! unless eligibility_data.eligible_status?
        reset_form_data
        redirect_to_step :complete
      end
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API: " + e.message)
      store_validation_data!(api_failure: true)
      reset_form_data
      redirect_to_step :complete
    end

    def store_validation_data!(opts = {})
      participant.create_ecf_participant_validation_data!({
        trn: @form.trn,
        full_name: @form.name,
        date_of_birth: @form.date_of_birth,
        nino: @form.national_insurance_number,
      }.merge(opts))
    end

    def store_trn!(trn)
      if participant.teacher_profile.trn.present? && participant.teacher_profile.trn != trn
        Rails.logger.warn("Different TRN already set for user [#{current_user.email}]")
      else
        participant.teacher_profile.update!(trn: trn)
      end
    end

    def store_eligibility_data!(dqt_data)
      participant.create_ecf_participant_eligibility!(qts: dqt_data[:qts],
                                                      active_flags: dqt_data[:active_alert] != "No",
                                                      previous_participation: false,
                                                      previous_induction: false)
    end

    def participant
      @participant ||= current_user.participant_profiles.active.ecf.first
    end

    def set_form
      @form = ParticipantValidationForm.new(session[:participant_validation])
      @form.assign_attributes(form_params)

      if @form.step.blank?
        @form.step = :start
      elsif @form.step != action_name
        redirect_to_step action_name
      end
    end

    def reset_form_data
      session.delete(:participant_validation)
    end

    def step_valid?
      @form.valid?(@form.step.to_sym)
    end

    def redirect_to_step(step)
      @form.step = step
      session[:participant_validation] = @form.attributes
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
