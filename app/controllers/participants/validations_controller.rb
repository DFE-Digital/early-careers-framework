# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    skip_before_action :ensure_participant, only: :reset
    before_action :set_form

    def start
      # check validation completed/manual
      # or start validation
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

    def cannot_find_details; end

    def complete
      @school = participant.school
    end

    def reset
      reset_form_data
      redirect_to participants_validation_start_path
    end

  private

    def validate_participant_details_and_redirect
      result = ParticipantValidationService.validate(trn: @form.trn,
                                                     full_name: @form.name,
                                                     date_of_birth: @form.date_of_birth,
                                                     nino: @form.national_insurance_number)
      if result.nil?
        # store form data in validation data
        store_validation_data!
        redirect_to_step :cannot_find_details
      else
        store_trn!(result[:trn])
        store_eligibility_data!
        redirect_to_step :complete
      end
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API: " + e.message)
      store_validation_data!
      redirect_to_step :manual_details_check
    end

    def store_validation_data!
      participant.create_participant_validation_data!(trn: @form.trn,
                                                      full_name: @form.name,
                                                      date_of_birth: @form.date_of_birth,
                                                      nino: @form.national_insurance_number)
    end

    def store_trn!(trn)
      if current_user.teacher_profile.trn.present? && current_user.teacher_profile.trn != trn
        Rails.logger.warning("Different TRN already set for user [#{current_user.email}]")
      else
        current_user.teacher_profile.update!(trn: trn)
      end
    end

    def store_eligibility_data!(dqt_data)
      participant.create_participation_eligibility!(qts: dqt[:qts],
                                                    active_flags: dqt[:active_alert] != "No",
                                                    previous_participation: false,
                                                    previous_induction: false)
    end

    def participant
      @participant ||= current_user.participant_profiles.active.ecf.first
    end

    def set_form
      @form = ParticipantValidationForm.new(session[:participant_validation])
      @form.assign_attributes(form_params)
      @form.step = action_name
    end

    def reset_form_data
      session.delete(:participant_validation)
    end

    def step_valid?
      @form.valid?(@form.step.to_sym)
    end

    def redirect_to_step(step)
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
