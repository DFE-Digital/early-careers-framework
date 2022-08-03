# frozen_string_literal: true

module Finance
  class ChangeTrainingStatusesController < BaseController
    before_action :set_participant_profile

    def new
      @change_training_status_form = Finance::ChangeTrainingStatusForm.new(
        participant_profile: @participant_profile,
      )
    end

    def create
      @change_training_status_form = Finance::ChangeTrainingStatusForm.new(change_training_status_form_params)
      @change_training_status_form.participant_profile = @participant_profile

      if @change_training_status_form.save
        set_success_message(heading: "Training status updated successfully.")
        redirect_to finance_participant_path(@change_training_status_form.participant_profile.user)
      else
        render :new
      end
    end

  private

    def set_participant_profile
      @participant_profile = ParticipantProfile.find(params[:participant_profile_id])
    end

    def change_training_status_form_params
      return {} unless params.key?(:finance_change_training_status_form)

      params.require(:finance_change_training_status_form).permit(
        :training_status,
        :reason,
      )
    end
  end
end
