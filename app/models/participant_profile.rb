# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  has_paper_trail

  self.ignored_columns = %w[user_id]

  attr_reader :participant_type

  class_attribute :validation_steps
  self.validation_steps = []

  DEFERRAL_REASONS = %w[
    bereavement
    long-term-sickness
    parental-leave
    career-break
    other
  ].freeze

  enum status: {
    active: "active",
    withdrawn: "withdrawn",
  }, _suffix: :record

  enum training_status: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }, _prefix: "training_status"

  # Associations
  belongs_to :participant_identity
  belongs_to :schedule, class_name: "Finance::Schedule"
  belongs_to :teacher_profile, touch: true

  has_many :current_induction_records, -> { current }, class_name: "InductionRecord"
  has_many :deleted_duplicates, class_name: "Finance::ECF::DeletedDuplicate", foreign_key: :primary_participant_profile_id
  has_many :induction_records
  has_many :participant_declarations
  has_many :participant_profile_schedules
  has_many :participant_profile_states
  has_many :sync_dqt_induction_start_date_errors
  has_many :validation_decisions, class_name: "ProfileValidationDecision"
  has_many :training_record_states, inverse_of: :participant_profile

  has_one :ecf_participant_eligibility
  has_one :ecf_participant_validation_data
  has_one :participant_profile_state, lambda {
    merge(ParticipantProfileState.most_recent)
  }, class_name: "ParticipantProfileState"
  has_one :user, through: :teacher_profile

  # Scopes
  scope :ecf, -> { where(type: [ECT.name, Mentor.name]) }
  scope :ects, -> { where(type: ECT.name) }
  scope :mentors, -> { where(type: Mentor.name) }
  scope :npqs, -> { where(type: NPQ.name) }

  # search by record state
  scope :record_state_different_trn, -> { joins(:training_record_states).where(training_record_states: { record_state: "different_trn" }) }
  scope :record_state_request_for_details_delivered, -> { joins(:training_record_states).where(training_record_states: { record_state: "request_for_details_delivered" }) }
  scope :record_state_request_for_details_failed, -> { joins(:training_record_states).where(training_record_states: { record_state: "request_for_details_failed" }) }
  scope :record_state_request_for_details_submitted, -> { joins(:training_record_states).where(training_record_states: { record_state: "request_for_details_submitted" }) }
  scope :record_state_validation_not_started, -> { joins(:training_record_states).where(training_record_states: { record_state: "validation_not_started" }) }
  scope :record_state_internal_error, -> { joins(:training_record_states).where(training_record_states: { record_state: "internal_error" }) }
  scope :record_state_tra_record_not_found, -> { joins(:training_record_states).where(training_record_states: { record_state: "tra_record_not_found" }) }
  scope :record_state_active_flags, -> { joins(:training_record_states).where(training_record_states: { record_state: "active_flags" }) }
  scope :record_state_not_allowed, -> { joins(:training_record_states).where(training_record_states: { record_state: "not_allowed" }) }
  scope :record_state_eligible_for_mentor_training_ero, -> { joins(:training_record_states).where(training_record_states: { record_state: "eligible_for_mentor_training_ero" }) }

  # search by validation state
  scope :validation_state_valid, -> { joins(:training_record_states).where(training_record_states: { validation_state: "valid" }) }

  # Instance Methods
  def approved?
    false
  end

  # cohort_start_year
  delegate :cohort_start_year, to: :latest_induction_record, allow_nil: true

  # delivery_partner
  delegate :delivery_partner, to: :latest_induction_record, allow_nil: true

  def duplicate?
    ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def ect?
    false
  end

  def eligible?
    ecf_participant_eligibility&.eligible_status?
  end

  # full_name
  delegate :full_name, :user_description, to: :user

  def fundable?
    false
  end

  def ineligible?
    ecf_participant_eligibility&.ineligible_status?
  end

  def latest_current_induction_record
    current_induction_records.first
  end

  def latest_induction_record
    induction_records.latest
  end

  # lead_provider
  delegate :lead_provider, to: :latest_induction_record, allow_nil: true

  def mentor?
    false
  end

  def no_qts?
    ecf_participant_eligibility&.no_qts_reason?
  end

  def npq?
    false
  end

  def pending?
    !approved? && !rejected?
  end

  def policy_class
    ParticipantProfilePolicy
  end

  def previous_induction?
    ecf_participant_eligibility&.previous_induction_reason?
  end

  def previous_participation?
    ecf_participant_eligibility&.previous_participation_reason?
  end

  def rejected?
    false
  end

  def request_for_details_sent?
    request_for_details_sent_at.present?
  end

  def role
    raise "Not implemented"
  end

  def sit_mentor?
    mentor? && user.induction_coordinator?
  end

  def state
    participant_profile_state&.state
  end

  def state_at(declaration_date)
    participant_profile_states.where("created_at < ?", declaration_date).order(:created_at).last
  end

  def update_schedule!(schedule)
    # TODO: Do we need to store when this happens outside of papertrail?
    update!(schedule:)
  end

  def validation_decision(name)
    unless self.class.validation_steps.include?(name.to_sym)
      raise "Unknown validation step: #{name} for #{self.class.name}. Known steps: #{self.class.validation_steps.join(', ')}"
    end

    decision = validation_decisions.find { |record| record.validation_step.to_s == name.to_s }
    decision || validation_decisions.build(validation_step: name)
  end
end

require "participant_profile/npq"
require "participant_profile/ecf"
