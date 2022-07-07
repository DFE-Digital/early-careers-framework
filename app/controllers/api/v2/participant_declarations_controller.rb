# frozen_string_literal: true

module Api
  module V2
    class ParticipantDeclarationsController < V1::ParticipantDeclarationsController
    private

      def serializer_class
        ParticipantDeclarationSerializer
      end
    end
  end
end
