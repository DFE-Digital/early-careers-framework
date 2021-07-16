# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile
  belongs_to :school_cohort
  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  belongs_to :core_induction_programme, optional: true

  def ect?
    true
  end

  def participant_type
    :ect
  end
end
