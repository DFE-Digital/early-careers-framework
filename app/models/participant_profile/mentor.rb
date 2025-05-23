# frozen_string_literal: true

class ParticipantProfile::Mentor < ParticipantProfile::ECF
  COURSE_IDENTIFIERS = %w[ecf-mentor].freeze

  has_many :mentee_profiles,
           class_name: "ParticipantProfile::ECT",
           foreign_key: :mentor_profile_id,
           dependent: :nullify
  has_many :mentees, through: :mentee_profiles, source: :user

  has_many :school_mentors, dependent: :destroy, foreign_key: :participant_profile_id
  has_many :schools, through: :school_mentors
  has_many :participant_declarations, class_name: "ParticipantDeclaration::Mentor", foreign_key: :participant_profile_id

  attribute :mentor_completion_reason, :string
  enum mentor_completion_reason: {
    completed_declaration_received: "completed_declaration_received",
    completed_during_early_roll_out: "completed_during_early_roll_out",
    started_not_completed: "started_not_completed",
  }

  def self.archivable_from_frozen_cohort(restrict_to_participant_ids: [])
    # Mentors that have at least one non-archivable declaration
    with_unarchivable_declaration = joins(:participant_declarations, schedule: :cohort)
                                      .where.not(cohorts: { payments_frozen_at: nil })
                                      .where(mentor_completion_date: nil)
                                      .where(participant_declarations: { state: ParticipantDeclaration.non_archivable_states })
                                      .distinct
    with_unarchivable_declaration = with_unarchivable_declaration.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    with_unarchivable_declaration_ids = with_unarchivable_declaration.pluck(:id)

    # Mentors ever assigned an ECT
    with_mentee = InductionRecord.joins(:induction_programme, mentor_profile: { schedule: :cohort })
                                 .where.not(mentor_profile_id: nil)
                                 .where.not(mentor_profile_id: with_unarchivable_declaration_ids)
                                 .where.not(cohorts: { payments_frozen_at: nil })
                                 .where(participant_profiles: { mentor_completion_date: nil })
    with_mentee = with_mentee.where(mentor_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    with_mentee_ids = with_mentee.pluck(:mentor_profile_id).uniq

    # Mentors in a payments frozen cohort with no completion date excluding the ones above
    query = joins(schedule: :cohort)
              .where.not(cohorts: { payments_frozen_at: nil })
              .where(mentor_completion_date: nil)
              .where.not(id: with_unarchivable_declaration_ids + with_mentee_ids)
    query = query.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query
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

  def self.unfinished_with_billable_declaration(cohort:, restrict_to_participant_ids: [])
    super(cohort:, restrict_to_participant_ids:).where(mentor_completion_date: nil)
  end
end
