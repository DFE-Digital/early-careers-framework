# frozen_string_literal: true

module Api
  module V3
    class ProviderOutcomesController < V1::ProviderOutcomesController
    private

      def serializer_class
        ParticipantOutcomeSerializer
      end
    end
  end
end
