# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  has_paper_trail
  belongs_to :teacher_profile, touch: true

  belongs_to :schedule, class_name: "Finance::Schedule", touch: true

  has_one :user, through: :teacher_profile

  has_many :validation_decisions, class_name: "ProfileValidationDecision"

  has_many :profile_declarations
  has_many :participant_declarations, through: :profile_declarations

  has_many :participant_profile_states
  has_one :participant_profile_state, lambda {
    merge(ParticipantProfileState.most_recent)
  }, class_name: "ParticipantProfileState"

  enum status: {
    active: "active",
    withdrawn: "withdrawn",
  }, _suffix: :record

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }
  scope :ecf, -> { where(type: [ECT.name, Mentor.name]) }

  scope :npqs, -> { where(type: NPQ.name) }

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }

  attr_reader :participant_type

  class_attribute :validation_steps
  self.validation_steps = []

  self.ignored_columns = %w[user_id]

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

  def fundable?
    false
  end

  def update_schedule!(schedule)
    # TODO: Do we need to store when this happens outside of papertrail?
    update!(schedule: schedule)
  end
end
