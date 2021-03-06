# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include Pagy::Backend

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
        LeadProviderApiToken.all
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
        participants = lead_provider.participants
                           .includes(
                             early_career_teacher_profile: %i[cohort mentor school],
                             mentor_profile: %i[cohort school],
                           )

        if updated_since.present?
          participants = participants.changed_since(updated_since)
        end

        participants
      end

      def paginate(scope)
        _pagy, paginated_records = pagy(scope, items: per_page, page: page)

        paginated_records
      end

      def per_page
        params[:page] ||= {}

        [(params.dig(:page, :per_page) || default_per_page).to_i, max_per_page].min
      end

      def default_per_page
        100
      end

      def max_per_page
        100
      end

      def page
        params[:page] ||= {}
        (params.dig(:page, :page) || 1).to_i
      end
    end
  end
end
