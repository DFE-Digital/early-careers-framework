# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  USER_TYPES = {
    early_career_teacher: "early_career_teacher",
    mentor: "mentor",
    other: "other",
  }.freeze

  CIP_TYPES = {
    ambition: "ambition",
    edt: "edt",
    teach_first: "teach_first",
    ucl: "ucl",
    none: "none",
  }.freeze

  set_id :id
  attributes :email, :full_name

  attributes :user_type do |user|
    if user.early_career_teacher?
      USER_TYPES[:early_career_teacher]
    elsif user.mentor?
      USER_TYPES[:mentor]
    else
      USER_TYPES[:other]
    end
  end

  attributes :core_induction_programme do |user|
    core_induction_programme = user.core_induction_programme || find_school_cohort(user)&.core_induction_programme

    case core_induction_programme&.name
    when "Ambition Institute"
      CIP_TYPES[:ambition]
    when "Education Development Trust"
      CIP_TYPES[:edt]
    when "Teach First"
      CIP_TYPES[:teach_first]
    when "UCL Institute of Education"
      CIP_TYPES[:ucl]
    else
      CIP_TYPES[:none]
    end
  end

  attributes :induction_programme_choice do |user|
    find_school_cohort(user)&.induction_programme_choice
  end

  # TODO: CPDRP-508 use the actual users registration completed value as part of participant validation journey
  attributes :registration_completed do
    false
  end

  def self.find_school_cohort(user)
    if user.participant?
      user.participant_profile.school_cohort
    end
  end
end
