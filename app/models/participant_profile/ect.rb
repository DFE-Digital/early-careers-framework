# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile::ECF
  COURSE_IDENTIFIERS = %w[ecf-induction].freeze

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  scope :awaiting_induction_registration, lambda {
    where(induction_start_date: nil).joins(:ecf_participant_eligibility).merge(ECFParticipantEligibility.waiting_for_induction)
  }

  def self.archivable(restrict_to_participant_ids: [])
    super(restrict_to_participant_ids:)
      .where(induction_completion_date: nil)
      .where("induction_start_date IS NULL OR induction_start_date < make_date(cohorts.start_year, 9, 1)")
  end

  def ect?
    true
  end

  def participant_type
    :ect
  end

  def role
    "Early career teacher"
  end

  def self.eligible_to_change_cohort_and_continue_training(in_cohort_start_year:, restrict_to_participant_ids: [])
    super(in_cohort_start_year:, restrict_to_participant_ids:).where(induction_completion_date: nil)
  end
end
