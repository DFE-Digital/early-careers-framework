# frozen_string_literal: true

module Api
  module V1
    module ParticipantActions
      def withdraw
        service = WithdrawParticipant.new(action_params)

        serialized_response_for(service)
      end

      def defer
        service = DeferParticipant.new(action_params)

        serialized_response_for(service)
      end

      def resume
        service = ResumeParticipant.new(action_params)

        serialized_response_for(service)
      end

      def change_schedule
        service = ChangeSchedule.new(action_params)

        serialized_response_for(service)
      end

    private

      def serialized_response_for(service)
        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

      def permitted_params
        params.require(:data).permit(:type, attributes: %i[course_identifier reason schedule_identifier cohort])
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end

      def participant_id
        params.require(:id)
      end

      def lead_provider
        current_user.lead_provider
      end

      def action_params
        HashWithIndifferentAccess.new(
          cpd_lead_provider: current_user,
          participant_id:,
        ).merge(permitted_params["attributes"] || {})
      end
    end
  end
end
