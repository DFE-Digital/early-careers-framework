# frozen_string_literal: true

class ParticipantProfile::Mentor < ParticipantProfile::ECF
  # self.ignored_columns = %i[mentor_profile_id school_id]

  COURSE_IDENTIFIERS = %w[ecf-mentor].freeze

  has_many :mentee_profiles,
           class_name: "ParticipantProfile::ECT",
           foreign_key: :mentor_profile_id,
           dependent: :nullify
  has_many :mentees, through: :mentee_profiles, source: :user

  has_many :school_mentors, dependent: :destroy, foreign_key: :participant_profile_id
  has_many :schools, through: :school_mentors

  attribute :mentor_completion_reason, :string
  enum mentor_completion_reason: {
    completed_declaration_received: "completed_declaration_received",
    completed_during_early_roll_out: "completed_during_early_roll_out",
    started_not_completed: "started_not_completed",
  }

  def self.archivable(restrict_to_participant_ids: [])
    super(restrict_to_participant_ids:)
      .where(mentor_completion_date: nil)
      .where.not(id: InductionRecord.where.not(mentor_profile_id: nil).select(:mentor_profile_id).distinct)
  end

  def complete_training!(completion_date:, completion_reason:)
    self.mentor_completion_date = completion_date
    self.mentor_completion_reason = completion_reason
    save!
  end

  def completed_training?
    mentor_completion_date.present?
  end

  def mentor?
    true
  end

  def participant_type
    :mentor
  end

  def role
    "Mentor"
  end

  def with_completion_date_status_or_declaration?
    mentor_completion_date.present? ||
      participant_declarations.billable.for_declaration(:completed).exists? ||
      latest_induction_record&.completed_induction_status?
  end

  def self.eligible_to_change_cohort_and_continue_training(cohort:, restrict_to_participant_ids: [])
    super(cohort:, restrict_to_participant_ids:).where(mentor_completion_date: nil)
  end
end
