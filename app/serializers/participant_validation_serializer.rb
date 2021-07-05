# frozen_string_literal: true

class ParticipantValidationSerializer
  include JSONAPI::Serializer

  set_id :trn
  attributes :trn, :qts, :active_alert
end
