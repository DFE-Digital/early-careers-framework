# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V2
    class ParticipantValidationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :trn
      attributes :trn, :qts, :active_alert
    end
  end
end
