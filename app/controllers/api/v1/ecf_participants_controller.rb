# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter

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

      def lead_provider
        current_user.lead_provider
      end

      def participants
        participants = lead_provider.ecf_participants
                                    .distinct
                                    .includes(
                                      teacher_profile: {
                                        ecf_profile_2021: %i[cohort school ecf_participant_eligibility ecf_participant_validation_data participant_profile_state participant_profile_states schedule],
                                        early_career_teacher_profile: :mentor,
                                      },
                                    )
                                    .where(school_cohorts: { cohort_id: Cohort.current.id })

        participants = participants.changed_since(updated_since) if updated_since.present?

        participants.order(:created_at)
      end
    end
  end
end
