# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeTrainingStatusesController < BaseController
      before_action :participant_profile

      def new
        change_training_status_form
      end

      def create
        change_training_status_form.assign_attributes(change_training_status_form_params)

        return render :new unless change_training_status_form.valid?

        change_training_status_form.save # rubocop:disable Rails/SaveBang

        set_success_message(heading: "Training status updated successfully.")
        redirect_to finance_participant_path(participant_profile.user)
      end

    private

      def participant_profile
        @participant_profile ||= ParticipantProfile.find(params[:participant_profile_id])
      end

      def change_training_status_form_params
        return {} unless params.key?(:finance_npq_change_training_status_form)

        params.require(:finance_npq_change_training_status_form).permit(
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
