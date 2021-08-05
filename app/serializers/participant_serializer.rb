# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  class << self
    def active_participant_attribute(attr, &blk)
      attribute attr do |user|
        blk.call(user) if participant_active?(user)
      end
    end

    def participant_active?(user)
      user.teacher_profile.ecf_profile&.active?
    end
  end

  set_id :id
  active_participant_attribute :email, &:email

  active_participant_attribute :full_name, &:full_name

  active_participant_attribute :mentor_id do |user|
    user.teacher_profile.early_career_teacher_profile&.mentor&.id
  end

  active_participant_attribute :school_urn do |user|
    user.teacher_profile.ecf_profile&.school&.urn
  end

  active_participant_attribute :participant_type do |user|
    case user.teacher_profile.ecf_profile.type
    when ParticipantProfile::ECT.name
      :ect
    when ParticipantProfile::Mentor.name
      :mentor
    end
  end

  active_participant_attribute :cohort do |user|
    user.teacher_profile.ecf_profile.cohort.start_year
  end

  attribute :status do |user|
    user.teacher_profile.ecf_profile&.status || "withdrawn"
  end

  active_participant_attribute :teacher_reference_number do |user|
    user.teacher_profile.trn
  end

  active_participant_attribute :teacher_reference_number_validated do |user|
    user.teacher_profile.trn.present?
  end
end
