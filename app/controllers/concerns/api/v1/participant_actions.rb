# frozen_string_literal: true

module Api
  module V1
    module ParticipantActions
      def withdraw
        service = WithdrawParticipant.new(params_for_recorder)
        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

      def defer
        service = DeferParticipant.new(params_for_recorder)

        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

      def resume
        service = ResumeParticipant.new(params_for_recorder)

        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

      def change_schedule
        service = ChangeSchedule.new(params_for_recorder)

        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

    private

      def serialized_response(profile)
        relevant_induction_record = profile.relevant_induction_record(lead_provider:)

        ParticipantFromInductionRecordSerializer
          .new(relevant_induction_record, params: { lead_provider: current_user.lead_provider })
          .serializable_hash.to_json
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

      def course_identifier
        permitted_params.dig(:attributes, :course_identifier)
      end

      def params_for_recorder
        HashWithIndifferentAccess.new(
          cpd_lead_provider: current_user,
          participant_id:,
        ).merge(permitted_params["attributes"] || {})
      end
    end
  end
end
