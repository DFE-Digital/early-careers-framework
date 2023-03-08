# frozen_string_literal: true

class ParticipantIdentityResolver
  def initialize(user_id:, course_identifier:, cpd_lead_provider:)
    @user_id = user_id
    @course_identifier = course_identifier
    @cpd_lead_provider = cpd_lead_provider
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    return if user_id.blank?
    return participant_identity unless FeatureFlag.active?(:external_identifier_to_user_id_lookup)

    if ParticipantProfile::ECT::COURSE_IDENTIFIERS.include?(course_identifier)
      ParticipantIdentity
        .joins(:participant_profiles)
        .where(participant_profiles: { type: "ParticipantProfile::ECT" })
        .where(user_id:)
        .first
    elsif ParticipantProfile::Mentor::COURSE_IDENTIFIERS.include?(course_identifier)
      ParticipantIdentity
        .joins(:participant_profiles)
        .where(participant_profiles: { type: "ParticipantProfile::Mentor" })
        .where(user_id:)
        .first
    elsif NPQCourse.identifiers.include?(course_identifier)
      ParticipantIdentity
        .joins(:npq_participant_profiles, npq_applications: [:npq_course, { npq_lead_provider: :cpd_lead_provider }])
        .where(npq_courses: { identifier: course_identifier })
        .where(npq_applications: { npq_lead_providers: { cpd_lead_provider: } })
        .where(user_id:)
        .first
    end
  end

private

  attr_reader :user_id, :course_identifier, :cpd_lead_provider

  def participant_identity
    @participant_identity ||= ParticipantIdentity.find_by(external_identifier: user_id)
  end
end
