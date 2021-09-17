# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable

      def index
        redirect_to controller: "ecf_participants", action: "index", params: request.params and return
      end

      def defer
        perform_action(service_namespace: ::Participants::Defer)
      end

      def resume
        perform_action(service_namespace: ::Participants::Resume)
      end

      def withdraw
        perform_action(service_namespace: ::Participants::Withdraw)
      end

      def change_schedule
        perform_action(service_namespace: ::Participants::ChangeSchedule)
      end

    private

      def perform_action(service_namespace:)
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: current_user, participant_id: participant_id }).merge(permitted_params["attributes"] || {})
        profile = recorder(service_namespace: service_namespace, params: params).call(params: params)
        render json: ParticipantSerializer.new(profile.user).serializable_hash.to_json
      end

      def recorder(service_namespace:, params:)
        "#{service_namespace}::#{::Factories::CourseIdentifier.call(params[:course_identifier])}".constantize
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def lead_provider
        current_user.lead_provider
      end

      def participant_id
        params.require(:id)
      end

      def permitted_params
        params.require(:data).permit(:type, attributes: {})
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end
    end
  end
end
