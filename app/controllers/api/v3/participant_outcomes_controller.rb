# frozen_string_literal: true

module Api
  module V3
    class ParticipantOutcomesController < V1::ParticipantOutcomesController
    private

      def serializer_class
        ParticipantOutcomeSerializer
      end
    end
  end
end
