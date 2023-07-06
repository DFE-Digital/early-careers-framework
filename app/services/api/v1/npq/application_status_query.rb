# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApplicationStatusQuery
        def initialize(npq_applications)
          @npq_applications = npq_applications
        end

        def call
          @npq_applications.map do |npq_application|
            declaration = NPQApplication.participant_declaration_finder(npq_application.last)
            { npq_application:, participant_outcome_state: declaration&.latest_outcome_state_of_declaration }
          end
        end
      end
    end
  end
end
