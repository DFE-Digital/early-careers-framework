# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile::ECF
  COURSE_IDENTIFIERS = %w[ecf-induction].freeze

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  def ect?
    true
  end

  def participant_type
    :ect
  end

  def role
    "Early career teacher"
  end
end
