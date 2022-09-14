# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeTrainingStatusesController < BaseController
      def new
        change_training_status_form
      end

      def create
        change_training_status_form.assign_attributes(change_training_status_form_params)

        if change_training_status_form.save
          set_success_message(heading: "Training status updated successfully.")
          redirect_to finance_participant_path(participant_profile.user)
        else
          render :new
        end
      end

    private

      def participant_profile
        @participant_profile ||= ParticipantProfile.find(params[:participant_profile_id])
      end

      def change_training_status_form_params
        params.fetch(:finance_npq_change_training_status_form, {}).permit(
          :training_status,
          :reason,
        )
      end

      def change_training_status_form
        @change_training_status_form ||= Finance::NPQ::ChangeTrainingStatusForm.new(participant_profile:)
      end
    end
  end
end
