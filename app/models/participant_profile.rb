# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  has_paper_trail

  DEFERRAL_REASONS = %w[
    bereavement
    long-term-sickness
    parental-leave
    career-break
    other
  ].freeze

  belongs_to :teacher_profile, touch: true
  belongs_to :schedule, class_name: "Finance::Schedule"
  belongs_to :participant_identity

  has_one :user, through: :teacher_profile

  has_many :validation_decisions, class_name: "ProfileValidationDecision"

  has_many :participant_declarations

  has_many :induction_records
  has_many :current_induction_records, -> { current }, class_name: "InductionRecord"
  has_one :ecf_participant_eligibility
  has_one :ecf_participant_validation_data

  has_many :participant_profile_states
  has_one :participant_profile_state, lambda {
    merge(ParticipantProfileState.most_recent)
  }, class_name: "ParticipantProfileState"

  has_many :participant_profile_schedules

  enum status: {
    active: "active",
    withdrawn: "withdrawn",
  }, _suffix: :record

  enum training_status: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }, _prefix: "training_status"

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }
  scope :ecf, -> { where(type: [ECT.name, Mentor.name]) }

  scope :npqs, -> { where(type: NPQ.name) }

  attr_reader :participant_type

  class_attribute :validation_steps
  self.validation_steps = []

  self.ignored_columns = %w[user_id]

  delegate :full_name, :user_description, to: :user

  def latest_induction_record
    induction_records.latest
  end

  def state
    participant_profile_state&.state
  end

  def ect?
    false
  end

  def mentor?
    false
  end

  def npq?
    false
  end

  def approved?
    false
  end

  def rejected?
    false
  end

  def pending?
    !approved? && !rejected?
  end

  def request_for_details_sent?
    request_for_details_sent_at.present?
  end

  def validation_decision(name)
    unless self.class.validation_steps.include?(name.to_sym)
      raise "Unknown validation step: #{name} for #{self.class.name}. Known steps: #{self.class.validation_steps.join(', ')}"
    end

    decision = validation_decisions.find { |record| record.validation_step.to_s == name.to_s }
    decision || validation_decisions.build(validation_step: name)
  end

  def state_at(declaration_date)
    participant_profile_states.where("created_at < ?", declaration_date).order(:created_at).last
  end

  def fundable?
    false
  end

  def update_schedule!(schedule)
    # TODO: Do we need to store when this happens outside of papertrail?
    update!(schedule:)
  end

  def sit_mentor?
    mentor? && user.induction_coordinator?
  end

  def policy_class
    ParticipantProfilePolicy
  end

  def role
    raise "Not implemented"
  end

  def latest_current_induction_record
    current_induction_records.first
  end
end

require "participant_profile/npq"
require "participant_profile/ecf"
