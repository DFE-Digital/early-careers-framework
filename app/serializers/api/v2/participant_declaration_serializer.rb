# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V2
    class ParticipantDeclarationSerializer < V1::ParticipantDeclarationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation
    end
  end
end
