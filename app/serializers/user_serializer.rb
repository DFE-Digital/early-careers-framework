# frozen_string_literal: true

USER_TYPES = {
  early_career_teacher: "early_career_teacher",
  other: "other",
}.freeze

CIP_TYPES = {
  ambition: "ambition",
  edt: "edt",
  teach_first: "teach_first",
  ucl: "ucl",
  none: "none",
}.freeze

class UserSerializer
  include JSONAPI::Serializer

  set_id :id
  attributes :email, :full_name

  attributes :user_type do |user|
    # TODO: Add Mentors
    if user.early_career_teacher?
      USER_TYPES[:early_career_teacher]
    else
      USER_TYPES[:other]
    end
  end

  attributes :core_induction_programme do |user|
    case user.core_induction_programme&.name
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
end
