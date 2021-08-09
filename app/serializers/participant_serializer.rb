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
      user.early_career_teacher_profile&.active? || user.mentor_profile&.active?
    end
  end

  set_id :id
  active_participant_attribute :email, &:email

  active_participant_attribute :full_name, &:full_name

  active_participant_attribute :mentor_id do |user|
    user.early_career_teacher_profile&.mentor&.id
  end

  active_participant_attribute :school_urn do |user|
    user.early_career_teacher_profile&.school&.urn ||
      user.mentor_profile&.school&.urn
  end

  attribute :participant_type do |user|
    if user.early_career_teacher?
      :ect
    elsif user.mentor?
      :mentor
    end
  end

  active_participant_attribute :cohort do |user|
    user.early_career_teacher_profile&.cohort&.start_year ||
      user.mentor_profile.cohort&.start_year
  end

  attribute :status do |user|
    user.early_career_teacher_profile&.status || user.mentor_profile&.status || "permanently_inactive"
  end
end
