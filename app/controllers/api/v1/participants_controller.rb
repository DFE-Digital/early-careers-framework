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
        params.dig(:filter, :updated_since)
      end

      def lead_provider
        current_user.lead_provider
      end

      def participants
        participants = lead_provider.ecf_participants
                                    .distinct
                                    .includes(
                                      teacher_profile: {
                                        ecf_profile: %i[cohort school],
                                        early_career_teacher_profile: :mentor,
                                      },
                                    )

        if updated_since.present?
          participants = participants.changed_since(updated_since)
        end

        participants
      end
    end
  end
end
