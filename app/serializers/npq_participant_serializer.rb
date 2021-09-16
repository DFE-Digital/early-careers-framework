# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class NPQParticipantSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  set_type :'npq-participant'

  attributes :participant_id, :date_of_birth, :teacher_reference_number, :teacher_reference_number_verified, :active_alert,
             :school_urn, :school_ukprn, :headteacher_status, :eligible_for_funding, :funding_choice

  attribute(:participant_id, &:user_id)
end
