# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"
ActiveSupport::Deprecation.warn("eligible_for_payment is deprecated as a returnable value for declarations")
ActiveSupport::Deprecation.warn("voided is deprecated as a returnable value for declarations")

class ParticipantDeclarationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  set_type :'participant-declaration'
  attributes :participant_id, :declaration_type, :course_identifier

  attribute :eligible_for_payment do |declaration|
    declaration.payable? || declaration.eligible?
  end

  attribute :declaration_date do |declaration|
    declaration.declaration_date.rfc3339
  end

  attribute :voided, &:voided?

  attribute(:participant_id, &:user_id)

  attribute :state, &:current_state
end
