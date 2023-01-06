# frozen_string_literal: true

module Finance
  module ECF
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

      def induction_record
        @induction_record ||= participant_profile.induction_records.find(params[:induction_record_id])
      end

      def change_training_status_form_params
        params.fetch(:finance_ecf_change_training_status_form, {}).permit(
          :training_status,
          :reason,
        )
      end

      def change_training_status_form
        @change_training_status_form ||= Finance::ECF::ChangeTrainingStatusForm.new(participant_profile:, induction_record:)
      end
    end
  end
end
