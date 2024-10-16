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

  def self.archivable_from_frozen_cohort(restrict_to_participant_ids: [])
    archivable_states = %i[ineligible voided submitted].freeze

    # ECTs that have no FIP induction records
    not_fip = InductionRecord.joins(:induction_programme, participant_profile: { schedule: :cohort })
                             .where.not(cohorts: { payments_frozen_at: nil })
                             .where(participant_profiles: { mentor_completion_date: nil })
                             .where(participant_profiles: { type: "ParticipantProfile::Mentor" })
                             .where.not(induction_programme: { training_programme: :full_induction_programme })
    not_fip = not_fip.where(participant_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    not_fip_ids = not_fip.pluck(:participant_profile_id).uniq

    # Mentors that have at least one non-archivable declaration
    with_unarchivable_declaration = joins(:participant_declarations, schedule: :cohort)
                                      .where.not(cohorts: { payments_frozen_at: nil })
                                      .where(mentor_completion_date: nil)
                                      .where.not(id: not_fip_ids)
                                      .where.not(participant_declarations: { state: archivable_states })
                                      .distinct
    with_unarchivable_declaration = with_unarchivable_declaration.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    with_unarchivable_declaration_ids = with_unarchivable_declaration.pluck(:id)

    # Mentors ever assigned an ECT
    with_mentee = InductionRecord.joins(:induction_programme, :participant_profile)
                                 .where(participant_profiles: { type: "ParticipantProfile::ECT" })
                                 .where.not(mentor_profile_id: nil)
                                 .where.not(mentor_profile_id: not_fip_ids + with_unarchivable_declaration_ids)
    with_mentee = with_mentee.where(mentor_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    with_mentee_ids = with_mentee.pluck(:mentor_profile_id).uniq

    # Mentors in a payments frozen cohort with no completion date excluding the ones above
    query = joins(schedule: :cohort)
              .where.not(cohorts: { payments_frozen_at: nil })
              .where(mentor_completion_date: nil)
              .where.not(id: not_fip_ids + with_unarchivable_declaration_ids + with_mentee_ids)
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

  def self.eligible_to_change_cohort_and_continue_training(cohort:, restrict_to_participant_ids: [])
    super(cohort:, restrict_to_participant_ids:).where(mentor_completion_date: nil)
  end
end
