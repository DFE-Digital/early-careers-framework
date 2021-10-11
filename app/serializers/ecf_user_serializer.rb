# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ECFUserSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  set_type :user

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
    case user.teacher_profile.ecf_profile&.type
    when ParticipantProfile::ECT.name
      USER_TYPES[:early_career_teacher]
    when ParticipantProfile::Mentor.name
      USER_TYPES[:mentor]
    else
      USER_TYPES[:other]
    end
  end

  attributes :core_induction_programme do |user|
    core_induction_programme = find_core_induction_programme(user)

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

  attributes :registration_completed do |user|
    user.teacher_profile.ecf_profile&.completed_validation_wizard?
  end

  attributes :cohort do |user|
    find_school_cohort(user)&.cohort&.start_year
  end

  def self.find_school_cohort(user)
    user.teacher_profile.ecf_profile&.school_cohort
  end

  def self.find_core_induction_programme(user)
    user.teacher_profile.ecf_profile&.core_induction_programme ||
      find_school_cohort(user)&.core_induction_programme
  end
end
