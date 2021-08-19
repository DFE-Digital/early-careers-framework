# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantDeclarationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  attributes :participant_id, :declaration_type, :declaration_date, :course_identifier

  attributes :eligible_for_payment do |participant_declaration|
    participant_declaration.profile_declaration.participant_profile.ecf_participant_eligibility&.status == "eligible"
  end

  attribute(:participant_id, &:user_id)
end
