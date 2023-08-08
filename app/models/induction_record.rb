# frozen_string_literal: true

class InductionRecord < ApplicationRecord
  has_paper_trail

  self.ignored_columns = %w[status]

  enum induction_status: {
    active: "active",
    withdrawn: "withdrawn",
    changed: "changed",
    leaving: "leaving",
    completed: "completed",
  }, _suffix: true

  enum training_status: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }, _prefix: "training_status"

  # Associations
  belongs_to :appropriate_body, optional: true
  belongs_to :induction_programme
  belongs_to :mentor_profile, class_name: "ParticipantProfile::Mentor", optional: true
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  belongs_to :preferred_identity, class_name: "ParticipantIdentity", optional: true
  belongs_to :schedule, class_name: "Finance::Schedule"

  has_one :cpd_lead_provider, through: :induction_programme
  has_one :mentor, through: :mentor_profile, source: :user
  has_one :partnership, through: :induction_programme
  has_one :school_cohort, through: :induction_programme

  has_one :cohort, through: :school_cohort
  has_one :delivery_partner, through: :partnership
  has_one :lead_provider, through: :partnership
  has_one :school, through: :school_cohort
  has_one :user, through: :participant_profile

  # Validations
  validates :start_date, presence: true

  # Scopes
  scope :fip, -> { joins(:induction_programme).merge(InductionProgramme.full_induction_programme) }
  scope :cip, -> { joins(:induction_programme).merge(InductionProgramme.core_induction_programme) }

  scope :end_date_in_future, -> { where(end_date: Time.zone.now...) }
  scope :end_date_in_past, -> { where(end_date: ...Time.zone.now) }
  scope :end_date_null, -> { where(end_date: nil) }
  scope :start_date_in_future, -> { where(start_date: Time.zone.now...) }
  scope :start_date_in_past, -> { where(start_date: ...Time.zone.now) }

  scope :school_transfer, -> { where(school_transfer: true) }
  scope :not_school_transfer, -> { where(school_transfer: false) }

  scope :active, -> { active_induction_status.merge(end_date_null.or(end_date_in_future)).and(start_date_in_past.or(not_school_transfer)) }
  scope :current, -> { active.or(transferring_out).or(claimed_by_another_school) }

  scope :transferring_in, -> { active_induction_status.merge(start_date_in_future.and(school_transfer)) }
  scope :transferring_out, -> { leaving_induction_status.merge(end_date_in_future.and(school_transfer)) }
  scope :claimed_by_another_school, -> { leaving_induction_status.merge(end_date_in_future.and(not_school_transfer)) }
  scope :transferred, -> { leaving_induction_status.merge(end_date_in_past) }

  scope :current_or_transferring_in, -> { current.or(transferring_in) }
  scope :current_or_transferring_in_or_transferred, -> { current.or(transferring_in).or(transferred) }

  scope :ects, -> { joins(:participant_profile).merge(ParticipantProfile.ects) }
  scope :mentors, -> { joins(:participant_profile).merge(ParticipantProfile.mentors) }

  scope :for_school, ->(school) { joins(:school).where(school: { id: school.id }) }

  scope :oldest_first, -> { order(Arel.sql("CASE WHEN induction_records.end_date IS NULL THEN 1 ELSE 0 END"), start_date: :asc, end_date: :asc, created_at: :asc) }
  scope :newest_first, -> { order(Arel.sql("CASE WHEN induction_records.end_date IS NULL THEN 0 ELSE 1 END"), start_date: :desc, end_date: :desc, created_at: :desc) }

  scope :oldest, -> { oldest_first.first }

  # Callbacks
  after_save :update_analytics

  # Class Methods
  def self.latest
    newest_first.first
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[participant_profile user school_cohort induction_programme]
  end

  # Instance Methods
  # appropriate_body_name
  delegate :name, to: :appropriate_body, allow_nil: true, prefix: true

  def active?
    active_induction_status? && (end_unknown? || end_date.future?) && !transferring_in?
  end

  def changing!(date_of_change = Time.zone.now)
    update!(induction_status: :changed, end_date: date_of_change)
  end

  def claimed_by_another_school?
    leaving_induction_status? && !school_transfer && end_date.future?
  end

  # cohort_start_year
  delegate :start_year, to: :cohort, prefix: true

  # core_induction_programme_name
  delegate :core_induction_programme_name, to: :induction_programme

  def current?
    active? || transferring_out? || claimed_by_another_school?
  end

  # delivery_partner_name. This will return nil if the partnership is challenged
  delegate :delivery_partner_name, to: :induction_programme

  def enrolled_in_cip?
    induction_programme.core_induction_programme?
  end

  def enrolled_in_fip?
    induction_programme.full_induction_programme?
  end

  # lead_provider_name. This will return nil if the partnership is challenged
  delegate :lead_provider_name, to: :induction_programme

  # Set transferring_out to true if this action originates from the school the participant is leaving
  def leaving!(date_of_change = Time.zone.now, transferring_out: false)
    update!(induction_status: :leaving, end_date: date_of_change, school_transfer: transferring_out)
  end

  def matches_school_appropriate_body?
    appropriate_body_id == school_cohort.appropriate_body_id
  end

  # ect?
  delegate :ect?, to: :participant_profile, allow_nil: true

  # mentor?
  delegate :mentor?, to: :participant_profile, allow_nil: true

  # mentor_full_name
  delegate :full_name, to: :mentor, allow_nil: true, prefix: true

  # participant_completed_validation_wizard?
  delegate :completed_validation_wizard?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_contacted_for_info?
  delegate :contacted_for_info?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_full_name
  delegate :full_name, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_fundable?
  delegate :fundable?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_ineligible_and_duplicated_or_previously_participated?
  delegate :ineligible_and_duplicated_or_previously_participated?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_ineligible_but_not_duplicated_or_previously_participated?
  delegate :ineligible_but_not_duplicated_or_previously_participated?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_manual_check_needed?
  delegate :manual_check_needed?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_no_qts?
  delegate :no_qts?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_preferred_identity
  delegate :email, to: :preferred_identity, allow_nil: true, prefix: :participant

  # participant_previous_participation?
  delegate :previous_participation?, to: :participant_profile, allow_nil: true, prefix: :participant

  # participant_type
  delegate :type, to: :participant_profile, allow_nil: true, prefix: :participant

  # schedule_identifier
  delegate :schedule_identifier, to: :schedule, allow_nil: true

  # school_name
  delegate :name, :urn, to: :school, prefix: true

  # training_programme
  delegate :training_programme, to: :induction_programme

  def transferred?
    leaving_induction_status? && end_date.present? && end_date.past?
  end

  def deferred_or_transferred?
    training_status_deferred? || transferred?
  end

  def transferring_in?
    active_induction_status? && start_date.future? && school_transfer
  end

  def transferring_out?
    leaving_induction_status? && end_date.present? && end_date.future? && school_transfer
  end

  # trn
  delegate :trn, to: :participant_profile, allow_nil: true

  def withdrawing!(date_of_change = Time.zone.now)
    update!(induction_status: :withdrawn, end_date: date_of_change)
  end

private

  def end_unknown?
    end_date.nil?
  end

  def update_analytics
    Analytics::UpsertECFInductionJob.perform_later(induction_record: self) if saved_changes?
  end
end
