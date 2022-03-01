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
             :school_ukprn,
             :headteacher_status,
             :eligible_for_funding,
             :funding_choice,
             :course_identifier,
             :works_in_school,
             :employer_name,
             :employment_role,
             :status,
             :created_at,
             :updated_at

  attribute(:participant_id) do |object|
    object.participant_identity.external_identifier
  end

  attribute(:teacher_reference_number_validated, &:teacher_reference_number_verified)

  attribute(:full_name) do |object|
    object.participant_identity.user.full_name
  end

  attribute(:email) do |object|
    object.participant_identity.email
  end

  attribute(:email_validated) do
    true
  end

  attribute(:course_identifier) do |object|
    object.npq_course.identifier
  end

  attribute :created_at do |object|
    object.created_at.rfc3339
  end

  attribute :updated_at do |object|
    object.updated_at.rfc3339
  end

  attribute(:status, &:lead_provider_approval_status)
end
