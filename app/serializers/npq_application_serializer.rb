# frozen_string_literal: true

class NpqApplicationSerializer
  include JSONAPI::Serializer

  attributes :id,
             :participant_id,
             :full_name,
             :email,
             :email_validated,
             :teacher_reference_number,
             :teacher_reference_number_validated,
             :school_urn,
             :headteacher_status,
             :eligible_for_funding,
             :funding_choice,
             :course_id,
             :course_name

  attribute(:participant_id) do |object|
    object.user_id
  end

  attribute(:full_name) do |object|
    object.user.full_name
  end

  attribute(:email) do |object|
    object.user.email
  end

  attribute(:email_validated) do |object|
    true
  end

  attribute(:teacher_reference_number_validated) do |object|
    object.teacher_reference_number_verified
  end

  attribute(:course_id) do |object|
    object.npq_course_id
  end

  attribute(:course_name) do |object|
    object.npq_course.name
  end
end
