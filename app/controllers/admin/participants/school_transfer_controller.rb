# frozen_string_literal: true

module Admin::Participants
  class SchoolTransferController < Admin::BaseController
    before_action :clear_session_data, only: :select_school, if: -> { request.get? }
    before_action :load_participant_profile
    before_action :load_school_transfer_form
    before_action :validate_and_proceed_or_render, only: %i[transfer_options start_date email]
    before_action :validate_request_or_render, only: %i[select_school cannot_transfer check_answers]

    def select_school
      step = if @school_transfer_form.cannot_transfer_to_new_school?
               :cannot_transfer
             else
               :transfer_options
             end
      store_form_and_redirect_to_next_step(step)
    end

    def cannot_transfer; end

    def transfer_options; end

    def start_date; end

    def email; end

    def check_answers
      @school_transfer_form.perform_transfer!
      clear_session_data

      set_success_message content: "#{@school_transfer_form.participant_name} has been successfully transferred"
      redirect_to admin_participant_path(@participant_profile)
    end

  private

    def load_school_transfer_form
      @school_transfer_form = if session_data.blank?
                                ::SchoolTransferForm.new(participant_profile_id: @participant_profile.id)
                              else
                                ::SchoolTransferForm.new(session_data)
                              end

      @school_transfer_form.assign_attributes(school_transfer_form_params)
      @school_transfer_form.current_step = action_name.to_sym

      if should_restart_process?
        clear_session_data
        redirect_to select_school_admin_participant_school_transfer_path(@participant_profile)
      end
    end

    def store_form_and_redirect_to_next_step(step)
      store_form
      redirect_to action: step
    end

    def school_transfer_form_params
      return {} unless params.key?(:school_transfer_form)

      params.require(:school_transfer_form).permit(:participant_profile_id, :new_school_urn, :transfer_choice, :start_date, :email)
    end

    def load_participant_profile
      @participant_profile = policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
        authorize participant_profile, :update?, policy_class: participant_profile.policy_class
      end
    end

    def step_valid?
      @school_transfer_form.valid? action_name.to_sym
    rescue StandardError
      clear_session_data
      redirect_to admin_participants_path
    end

    def validate_request_or_render
      render unless (request.put? || request.post?) && step_valid?
    end

    def validate_and_proceed_or_render
      if (request.put? || request.post?) && step_valid?
        store_form_and_redirect_to_next_step(@school_transfer_form.next_step)
      else
        render
      end
    end

    def should_restart_process?
      @participant_profile.id != @school_transfer_form.participant_profile_id || (session_data.blank? && action_name.to_sym != :select_school)
    end

    def session_data
      session[:school_transfer_form]
    end

    def clear_session_data
      session.delete(:school_transfer_form)
    end

    def store_form
      session[:school_transfer_form] = @school_transfer_form.serializable_hash
    end
  end
end
