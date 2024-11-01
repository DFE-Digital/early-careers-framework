# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile::ECF
  COURSE_IDENTIFIERS = %w[ecf-induction].freeze

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  scope :awaiting_induction_registration, lambda {
    where(induction_start_date: nil).joins(:ecf_participant_eligibility).merge(ECFParticipantEligibility.waiting_for_induction)
  }

  def self.archivable_from_frozen_cohort(restrict_to_participant_ids: [])
    # ECTs that have no FIP induction records
    not_fip = InductionRecord.joins(:induction_programme, participant_profile: { schedule: :cohort })
                             .where.not(cohorts: { payments_frozen_at: nil })
                             .where(participant_profiles: { induction_completion_date: nil })
                             .where(participant_profiles: { type: "ParticipantProfile::ECT" })
                             .where("participant_profiles.induction_start_date IS NULL OR participant_profiles.induction_start_date < make_date(cohorts.start_year, 9, 1)")
                             .where.not(induction_programme: { training_programme: :full_induction_programme })
    not_fip = not_fip.where(participant_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    not_fip_ids = not_fip.pluck(:participant_profile_id).uniq

    # ECTs that have at least one non-archivable declaration
    with_unarchivable_declaration = joins(:participant_declarations, schedule: :cohort)
                                      .where.not(cohorts: { payments_frozen_at: nil })
                                      .where(induction_completion_date: nil)
                                      .where("induction_start_date IS NULL OR induction_start_date < make_date(cohorts.start_year, 9, 1)")
                                      .where.not(id: not_fip_ids)
                                      .where(participant_declarations: { state: ParticipantDeclaration.non_archivable_states })
                                      .distinct
    with_unarchivable_declaration = with_unarchivable_declaration.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?
    with_unarchivable_declaration_ids = with_unarchivable_declaration.pluck(:id)

    # ECTs in a payments-frozen cohort with no induction start date or prior to Sept 2021 excluding the ones above
    query = joins(schedule: :cohort)
              .where.not(cohorts: { payments_frozen_at: nil })
              .where(induction_completion_date: nil)
              .where("induction_start_date IS NULL OR induction_start_date < make_date(cohorts.start_year, 9, 1)")
              .where.not(id: not_fip_ids + with_unarchivable_declaration_ids)
    query = query.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query
  end

  def completed_training?
    induction_completion_date.present?
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

  def self.unfinished_with_billable_declaration(cohort:, restrict_to_participant_ids: [])
    super(cohort:, restrict_to_participant_ids:).where(induction_completion_date: nil)
  end
end
