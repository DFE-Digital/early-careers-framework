# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantDeclarationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  attributes :participant_id, :declaration_type, :declaration_date, :course_identifier

  attribute(:eligible_for_payment, &:payable)
  attribute(:participant_id, &:user_id)
end
