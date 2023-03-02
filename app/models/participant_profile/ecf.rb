# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  self.ignored_columns = %i[school_id]

  VALID_EVIDENCE_HELD = %w[training-event-attended self-study-material-completed other].freeze
  COURSE_IDENTIFIERS = %w[ecf-mentor ecf-induction].freeze
  WITHDRAW_REASONS = %w[
    left-teaching-profession
    moved-school
    mentor-no-longer-being-mentor
    school-left-fip
    started-in-error
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

  # Instance Methods
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

  def schedule_for(cpd_lead_provider:)
    relevant_induction_record(lead_provider: cpd_lead_provider&.lead_provider)&.schedule
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
