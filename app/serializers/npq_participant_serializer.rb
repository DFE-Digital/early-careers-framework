# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class NPQParticipantSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  set_type :'npq-participant'

  attributes :participant_id, :email, :full_name

  attribute(:participant_id, &:id)

  attribute(:npq_courses) do |object|
    object.npq_profile&.npq_course&.identifier
  end

  attribute(:teacher_reference_number) do |object|
    object.npq_profile&.validation_data&.teacher_reference_number
  end

  attribute(:teacher_reference_number_validated) do |object|
    object.npq_profile&.validation_data&.eligible_for_funding
  end
end
