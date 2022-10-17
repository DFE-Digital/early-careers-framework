# frozen_string_literal: true

module Api
  module V2
    module ParticipantActions
      def withdraw
        perform_action(service_namespace: ::Participants::Withdraw)
      end

      def defer
        service = DeferParticipant.new(params_for_recorder)

        render_from_service(service, ParticipantFromInductionRecordSerializer, params: { lead_provider: })
      end

      def resume
        perform_action(service_namespace: ::Participants::Resume)
      end

      def change_schedule
        service = recorder(service_namespace: ::Participants::ChangeSchedule).new(params: params_for_recorder)
        render json: serialized_response(service.call)
      end

    private

      def relevant_induction_record_for_profile(profile)
        profile.relevant_induction_record(lead_provider:)
      end

      def perform_action(service_namespace:)
        render json: serialized_response(participant_profile_for(service_namespace))
      end

      def recorder(service_namespace:)
        "#{service_namespace}::#{::Factories::CourseIdentifier.call(course_identifier)}".constantize
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

      def participant_profile_for(service_namespace)
        recorder(service_namespace:).call(params: params_for_recorder)
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
