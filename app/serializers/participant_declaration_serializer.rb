# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantDeclarationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  set_type :'participant-declaration'
  attributes :participant_id, :declaration_type, :course_identifier

  attribute :eligible_for_payment do |declaration|
    declaration.payable || false
  end

  attribute :declaration_date do |declaration|
    declaration.declaration_date.rfc3339
  end

  attribute(:participant_id, &:user_id)
end
