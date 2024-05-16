# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile::ECF
  COURSE_IDENTIFIERS = %w[ecf-induction].freeze

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  scope :awaiting_induction_registration, lambda {
    where(induction_start_date: nil).joins(:ecf_participant_eligibility).merge(ECFParticipantEligibility.waiting_for_induction)
  }

  def ect?
    true
  end

  def participant_type
    :ect
  end

  def role
    "Early career teacher"
  end

  def can_change_cohort_and_continue_training?(cohort_start_year:)
    super(cohort_start_year:) && induction_completion_date.nil?
  end
end
