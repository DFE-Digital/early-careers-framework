# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApplicationStatusQuery
        def initialize(npq_application)
          @npq_application = npq_application
        end

        def call
          declaration = get_participant_declaration(@npq_application.participant_identity_id)
          return_participant_outcome_state(get_latest_participant_outcome, declaration)
        end

      private

        def get_participant_declaration(participant_identity_id)
          NPQApplication.participant_declaration_finder(participant_identity_id)
        end

        def get_latest_participant_outcome
          ParticipantOutcome::NPQ.latest_per_declaration
        end

        def return_participant_outcome_state(participant_outcomes, declaration)
          return participant_outcomes&.find_by_participant_declaration_id(declaration&.id)&.state if participant_outcomes.is_a?(Array)

          ParticipantOutcome::NPQ.find_by_participant_declaration_id(declaration&.id)&.state
        end
      end
    end
  end
end
