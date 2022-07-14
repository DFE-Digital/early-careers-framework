# frozen_string_literal: true

module Api
  module V2
    class NPQParticipantsController < V1::NPQParticipantsController
    private

      def serializer_class
        NPQParticipantSerializer
      end
    end
  end
end
