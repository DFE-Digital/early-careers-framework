# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class NPQParticipantSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_id :id
  set_type :'npq-participant'

  attributes :participant_id, :email, :full_name

  attribute(:participant_id, &:id)

  attribute(:npq_courses) do |object, params|
    object.npq_profiles.filter { |profile| provider_matches(profile, params) }.map { |npq_profile| npq_profile.npq_course.identifier }
  end

  attribute(:teacher_reference_number) do |object|
    object.teacher_profile&.trn
  end

  def self.provider_matches(profile, params)
    profile.npq_application&.npq_lead_provider&.cpd_lead_provider == params[:cpd_lead_provider]
  end
end
