# frozen_string_literal: true

module Schools
  class TransferOutController < ::Schools::BaseController
    before_action :load_transfer_out_form, except: %i[check_transfer]
    before_action :set_school_cohort
    before_action :set_participant
    before_action :validate_request_or_render, except: %i[check_transfer]

    skip_after_action :verify_authorized

    def check_transfer
      reset_form_data
    end

    def teacher_end_date
      store_form_redirect_to_next_step(:check_answers)
    end

    def check_answers
      @induction_record.leaving!(@transfer_out_form.end_date, transferring_out: true)
      ParticipantTransferMailer.with(induction_record: @induction_record).participant_transfer_out_notification.deliver_later

      store_form_redirect_to_next_step(:complete)
    end

  private

    def load_transfer_out_form
      @transfer_out_form = TransferOutForm.new(session[:schools_transfer_out_form])
      @transfer_out_form.assign_attributes(transfer_out_form_params)
    end

    def transfer_out_form_params
      return {} unless params.key?(:schools_transfer_out_form)

      params.require(:schools_transfer_out_form).permit(:end_date)
    end

    def validate_request_or_render
      render unless request.put? && step_valid?
    end

    def store_form_redirect_to_next_step(step)
      session[:schools_transfer_out_form] = @transfer_out_form.serializable_hash
      redirect_to action: step
    end

    def step_valid?
      @transfer_out_form.valid? action_name.to_sym
    end

    def set_participant
      @profile = ParticipantProfile.find(params[:transfer_out_participant_id])
      @induction_record = @profile.induction_records.for_school(@school).latest
    end

    def reset_form_data
      session.delete(:schools_transfer_out_form)
    end
  end
end
