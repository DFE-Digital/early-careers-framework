# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantValidationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :trn
  attributes :trn, :qts, :active_alert
end
