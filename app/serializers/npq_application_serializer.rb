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
             :status,
             :created_at,
             :updated_at

  # NOTE: only until identity data populated
  attribute(:participant_id, &:user_id)
  # then change to this
  # attribute(:participant_id) do |object|
  #   object.participant_identity.external_identifier
  # end

  attribute(:teacher_reference_number_validated, &:teacher_reference_number_verified)

  attribute(:full_name) do |object|
    # NOTE: only until identity data populated
    object.user.full_name
    # then change to this
    # object.participant_identity.user.full_name
  end

  attribute(:email) do |object|
    # NOTE: only until identity data populated
    object.user.email
    # then change to this
    # object.participant_identity.email
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
