# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApplicationStatusQuery
        attr_reader :npq_application

        def initialize(npq_application)
          @npq_application = npq_application
        end

        def call
          return unless completed_participant_declaration

          completed_participant_declaration.outcomes.latest&.state
        end

      private

        def completed_participant_declaration
          @completed_participant_declaration ||= npq_application.latest_completed_participant_declaration
        end
      end
    end
  end
end
