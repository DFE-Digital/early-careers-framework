# frozen_string_literal: true

class ParticipantSerializer
  include JSONAPI::Serializer

  set_id :id
  attribute :email do |user|
    if participant_active?(user)
      user.email
    end
  end

  attribute :full_name do |user|
    if participant_active?(user)
      user.full_name
    end
  end

  attributes :mentor_id do |user|
    if participant_active?(user)
      user.early_career_teacher_profile&.mentor&.id
    end
  end

  attributes :school_urn do |user|
    if participant_active?(user)
      user.early_career_teacher_profile&.school&.urn ||
        user.mentor_profile&.school&.urn
    end
  end

  attributes :participant_type do |user|
    if user.early_career_teacher_profile
      :ect
    else
      :mentor
    end
  end

  attributes :cohort do |user|
    if participant_active?(user)
      user.early_career_teacher_profile&.cohort&.start_year ||
        user.mentor_profile.cohort&.start_year
    end
  end

  attribute :status do |user|
    user.early_career_teacher_profile&.status || user.mentor_profile&.status
  end
end

def participant_active?(user)
  user.early_career_teacher_profile&.active? || user.mentor_profile&.active?
end
