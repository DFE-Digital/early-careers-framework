# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  # self.ignored_columns = %i[school_id]

  POST_TRANSITIONAL_INDUCTION_START_DATE_DEADLINE = ActiveSupport::TimeZone["London"].parse(Cohort::INITIAL_COHORT_START_DATE.to_s).freeze
  VALID_EVIDENCE_HELD = %w[training-event-attended self-study-material-completed other].freeze
  COURSE_IDENTIFIERS = %w[ecf-mentor ecf-induction].freeze
  WITHDRAW_REASONS = %w[
    left-teaching-profession
    moved-school
    mentor-no-longer-being-mentor
    school-left-fip
    other
  ].freeze

  enum profile_duplicity: {
    single: "single",
    primary: "primary",
    secondary: "secondary",
  }, _suffix: "profile"

  # Associations
  belongs_to :core_induction_programme, optional: true
  belongs_to :mentor_profile, -> { where(id: 0) }, class_name: "Mentor", optional: true
  belongs_to :school_cohort

  has_one :cohort, through: :school_cohort
  has_one :school, through: :school_cohort

  has_one :mentor, through: :mentor_profile, source: :user

  # Scopes
  scope :contacted_for_info, -> { where.missing(:ecf_participant_validation_data) }
  scope :current_cohort, -> { joins(:school_cohort).where(school_cohort: { cohort_id: Cohort.current.id }) }
  scope :details_being_checked, -> { joins(:ecf_participant_validation_data).left_joins(:ecf_participant_eligibility).where("ecf_participant_eligibilities.id IS NULL OR ecf_participant_eligibilities.status = 'manual_check'") }
  scope :eligible_status, lambda {
    joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :eligible })
      .or(joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible, reason: %i[previous_participation duplicate_profile] }))
  }
  scope :ineligible_status, -> { joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible }).where.not(ecf_participant_eligibility: { reason: %i[previous_participation duplicate_profile] }) }

  # Callbacks
  after_save :update_analytics
  after_update :sync_status_with_induction_record

  # Class methods
  def self.ransackable_attributes(_auth_object = nil)
    %w[id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[cohort participant_identity school user teacher_profile induction_records]
  end

  def self.eligible_to_change_cohort_and_continue_training(cohort:, restrict_to_participant_ids: [])
    billable_states = %w[eligible payable paid].freeze

    return none unless cohort == Cohort.active_registration_cohort

    completed_billable_declarations = ParticipantDeclaration.billable.for_declaration(:completed)
    completed_billable_declarations = completed_billable_declarations.where(participant_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query = joins(:participant_declarations, schedule: :cohort)
      .where.not(cohorts: { payments_frozen_at: nil })
      .where("participant_declarations.state IN (?) AND declaration_type != ?", billable_states, "completed")
      .where.not(id: completed_billable_declarations.select(:participant_profile_id))
      .distinct

    query = query.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query
  end

  def eligible_to_change_cohort_back_to_their_payments_frozen_original?(cohort:, current_cohort:)
    return false unless cohort_changed_after_payments_frozen?
    return false unless cohort.payments_frozen?
    return false if participant_declarations.billable_or_changeable.where(cohort: current_cohort).exists?

    participant_declarations.billable.where(cohort:).exists?
  end

  def self.archivable(restrict_to_participant_ids: [])
    unbillable_states = %i[ineligible voided submitted].freeze

    # Find all participants that have no FIP induction records (as finding those with only FIP is more complicated).
    not_fip_induction_records = InductionRecord.left_joins(:induction_programme).where.not(induction_programme: { training_programme: :full_induction_programme })
    not_fip_induction_records = not_fip_induction_records.where(participant_profile_id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query = left_joins(:participant_declarations, schedule: :cohort)
      # Exclude participants that have any induction records that are not FIP.
      .where.not(id: not_fip_induction_records.select(:participant_profile_id))
      .where.not(cohorts: { payments_frozen_at: nil })
      # Exclude participants that have any billable/submitted declarations, but
      # retain participants that have no declarations at all.
      .where.not("participant_declarations.id IS NOT NULL AND participant_declarations.state NOT IN (?)", unbillable_states)
      .distinct

    query = query.where(id: restrict_to_participant_ids) if restrict_to_participant_ids.any?

    query
  end

  # Instance Methods
  def eligible_to_change_cohort_and_continue_training?(cohort:)
    self.class.eligible_to_change_cohort_and_continue_training(cohort:, restrict_to_participant_ids: [id]).exists?
  end

  def archivable?
    self.class.archivable(restrict_to_participant_ids: [id]).exists?
  end

  def previous_payments_frozen_cohort
    return nil unless cohort_changed_after_payments_frozen?

    participant_declarations
      .includes(:cohort)
      .where.not(cohort: { payments_frozen_at: nil })
      .where.not(cohort: schedule.cohort)
      .pick("cohort.start_year")
  end

  def contacted_for_info?
    ecf_participant_validation_data.nil?
  end

  def completed_validation_wizard?
    ecf_participant_eligibility.present? || (ecf_participant_validation_data.present? && ecf_participant_validation_data.persisted?)
  end

  def current_induction_record
    induction_records.current&.latest
  end

  def current_induction_programme
    induction_records.current&.latest&.induction_programme
  end

  def ecf?
    true
  end

  def latest_induction_record_for(cpd_lead_provider:)
    relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider) unless cpd_lead_provider.nil?
  end

  delegate :ineligible_but_not_duplicated_or_previously_participated?,
           :ineligible_and_duplicated_or_previously_participated?,
           to: :ecf_participant_eligibility,
           allow_nil: true

  delegate :trn, to: :teacher_profile

  alias_method :fundable?, :eligible?

  def manual_check_needed?
    ecf_participant_eligibility&.manual_check_status? ||
      (ecf_participant_validation_data.present? && ecf_participant_eligibility.nil?)
  end

  def policy_class
    ParticipantProfile::ECFPolicy
  end

  def relevant_induction_record(lead_provider:)
    Induction::FindBy.call(participant_profile: self, lead_provider:) unless lead_provider.nil?
  end
  alias_method :record_to_serialize_for, :relevant_induction_record

  def relevant_induction_record_for(delivery_partner:)
    Induction::FindBy.call(participant_profile: self, delivery_partner:, only_active_partnerships: true) unless delivery_partner.nil?
  end

  def relevant_induction_record_for_school(school:)
    Induction::FindBy.call(participant_profile: self, school:) unless delivery_partner.nil?
  end

  def schedule_for(cpd_lead_provider:)
    relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider)&.schedule
  end

  def post_transitional?
    return false unless ect?
    return false unless induction_start_date
    return false if completed_training?

    induction_start_date < POST_TRANSITIONAL_INDUCTION_START_DATE_DEADLINE
  end

  def active_for?(cpd_lead_provider:)
    !!relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider)&.training_status_active?
  end

  def deferred_for?(cpd_lead_provider:)
    !!relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider)&.training_status_deferred?
  end

  def withdrawn_for?(cpd_lead_provider:)
    !!relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider)&.training_status_withdrawn?
  end

private

  def update_analytics
    Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile: self) if saved_changes?
  end

  def sync_status_with_induction_record
    induction_record = induction_records.latest
    induction_record&.update!(induction_status: status) if saved_change_to_status?
    induction_record&.update!(mentor_profile:) if saved_change_to_mentor_profile_id?
  end
end

require "participant_profile/ect"
require "participant_profile/mentor"
