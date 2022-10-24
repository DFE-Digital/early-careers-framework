# frozen_string_literal: true

module Api
  module V1
    class NPQParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter
      include ParticipantActions

      def index
        render json: serializer_class.new(paginate(npq_participants), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
      end

      def show
        render json: serializer_class.new(npq_participant, params: { cpd_lead_provider: current_user }).serializable_hash.to_json
      end

      def withdraw
        if any_participant_declarations_started?
          perform_action(service_namespace: ::Participants::Withdraw)
        else
          render json: {
            error: [{
              title: "No started declaration found",
              detail: "An NPQ participant who has not got a started declaration cannot be withdrawn. Please contact support for assistance.",
            }],
          }, status: :unprocessable_entity
        end
      end

      def defer
        service = DeferParticipant.new(params_for_recorder)

        render_from_service(service, serializer_class, params: { cpd_lead_provider: current_user })
      end

    private

      def serializer_class
        NPQParticipantSerializer
      end

      def serialized_response(participant_profile)
        serializer_class
          .new(participant_profile.user, params: { cpd_lead_provider: current_user })
          .serializable_hash.to_json
      end

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def npq_participants
        npq_participants = npq_lead_provider.npq_participants
        npq_participants = npq_participants.where("users.updated_at > ?", updated_since) if updated_since.present?
        npq_participants.order(:created_at)
        npq_participants
      end

      def npq_participant
        @npq_participant ||= npq_lead_provider.npq_participants.find(params[:id])
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end

      def any_participant_declarations_started?
        ParticipantDeclaration::NPQ
          .joins(participant_profile: [:npq_course])
          .joins(user: [:participant_identities])
          .where(
            "participant_identities.external_identifier": participant_id,
            "npq_courses.identifier": course_identifier,
            declaration_type: "started",
          ).any?
      end
    end
  end
end
