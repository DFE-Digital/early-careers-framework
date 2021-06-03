# frozen_string_literal: true

class ParticipantSerializer
  include JSONAPI::Serializer

  set_id :id
  attributes :email, :full_name

  attributes :mentor_id do |user|
    if user.early_career_teacher?
      user.early_career_teacher_profile.mentor&.id
    end
  end

  attributes :school_urn do |user|
    if user.early_career_teacher?
      user.early_career_teacher_profile.school.urn
    else
      user.mentor_profile.school.urn
    end
  end

  attributes :participant_type do |user|
    if user.early_career_teacher?
      :ect
    else
      :mentor
    end
  end

  attributes :cohort do |user|
    if user.early_career_teacher?
      user.early_career_teacher_profile.cohort&.start_year
    else
      user.mentor_profile.cohort&.start_year
    end
  end
end
