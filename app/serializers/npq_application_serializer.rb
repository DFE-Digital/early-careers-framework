# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class NPQApplicationSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  attributes :participant_id,
             :full_name,
             :email,
             :email_validated,
             :teacher_reference_number,
             :teacher_reference_number_validated,
             :school_urn,
             :headteacher_status,
             :eligible_for_funding,
             :funding_choice,
             :course_identifier,
             :status

  attribute(:participant_id, &:user_id)
  attribute(:teacher_reference_number_validated, &:teacher_reference_number_verified)

  attribute(:full_name) do |object|
    object.user.full_name
  end

  attribute(:email) do |object|
    object.user.email
  end

  attribute(:email_validated) do
    true
  end

  attribute(:course_identifier) do |object|
    object.npq_course.identifier
  end

  attribute(:status, &:lead_provider_approval_status)
end
