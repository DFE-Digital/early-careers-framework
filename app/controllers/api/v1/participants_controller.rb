# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination

      def index
        respond_to do |format|
          format.json do
            participant_hash = ParticipantSerializer.new(paginate(participants)).serializable_hash
            render json: participant_hash.to_json
          end
          format.csv do
            participant_hash = ParticipantSerializer.new(participants).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

      def withdraw
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: current_user, participant_id: participant_id }).merge(permitted_params["attributes"] || {})
        profile = WithdrawParticipant.call(params)
        render json: ParticipantSerializer.new(profile.user).serializable_hash.to_json
      end

      def change_schedule
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: current_user, participant_id: participant_id }).merge(permitted_params["attributes"] || {})
        profile = ChangeParticipantSchedule.call(params)
        render json: ParticipantSerializer.new(profile.user).serializable_hash.to_json
      end

    private

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def to_csv(hash)
        return "" if hash[:data].empty?

        headers = %w[id]
        attributes = hash[:data].first[:attributes].keys
        headers.concat(attributes.map(&:to_s))
        CSV.generate(headers: headers, write_headers: true) do |csv|
          hash[:data].each do |item|
            row = [item[:id]]
            row.concat(attributes.map { |attribute| item[:attributes][attribute].to_s })
            csv << row
          end
        end
      end

      def updated_since
        value = params.dig(:filter, :updated_since)
        URI.decode_www_form_component(value) if value.present?
      end

      def lead_provider
        current_user.lead_provider
      end

      def participants
        participants = lead_provider.ecf_participants
                                    .distinct
                                    .includes(
                                      teacher_profile: {
                                        ecf_profile: %i[cohort school ecf_participant_eligibility ecf_participant_validation_data participant_profile_state participant_profile_states schedule],
                                        early_career_teacher_profile: :mentor,
                                      },
                                    )

        if updated_since.present?
          participants = participants.changed_since(updated_since)
        end

        participants
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
