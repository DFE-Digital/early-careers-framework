# frozen_string_literal: true

module Api
  module V2
    class NPQEnrollmentsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      def index
        respond_to do |format|
          format.csv do
            render body: csv_response
          end
        end
      end

    private

      def npq_profiles
        @npq_profiles ||= ParticipantProfile::NPQ
          .joins(:npq_application)
          .includes(:user, :npq_course, :npq_application, schedule: [:cohort])
          .where(npq_application: { npq_lead_provider: })
          .order(updated_at: :asc)

        @npq_profiles = @npq_profiles.where("participant_profiles.updated_at > ?", updated_since) if updated_since.present?

        @npq_profiles
      end

      def csv_response
        @csv_response ||= NPQEnrollmentsCsvSerializer.new(scope: npq_profiles).call
      end

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end
    end
  end
end
