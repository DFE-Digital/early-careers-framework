# frozen_string_literal: true

class InductionRecord < ApplicationRecord
  has_paper_trail

  self.ignored_columns = %w[status]

  belongs_to :induction_programme
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  belongs_to :schedule, class_name: "Finance::Schedule"
  belongs_to :mentor_profile, class_name: "ParticipantProfile::Mentor", optional: true
  belongs_to :appropriate_body, optional: true

  has_one :mentor, through: :mentor_profile, source: :user
  has_one :school_cohort, through: :induction_programme
  has_one :cohort, through: :school_cohort
  has_one :school, through: :school_cohort
  has_one :user, through: :participant_profile
  has_one :partnership, through: :induction_programme
  has_one :lead_provider, through: :partnership
  has_one :delivery_partner, through: :partnership
  has_one :cpd_lead_provider, through: :induction_programme

  # optional while the data is setup
  # enables a different identity/email to be used for this induction
  # rather that the one tied to the participant_profile
  # This is needed to allow us to display the right email in the dashboard
  # and to enable participants transferring between schools (where they might be added with
  # a different email address) to still appear correctly at their old and new schools
  # and still be able to access CIP materials while moving
  belongs_to :preferred_identity, class_name: "ParticipantIdentity", optional: true

  validates :start_date, presence: true

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

  scope :fip, -> { joins(:induction_programme).merge(InductionProgramme.full_induction_programme) }
  scope :cip, -> { joins(:induction_programme).merge(InductionProgramme.core_induction_programme) }

  scope :end_date_null, -> { where(end_date: nil) }
  scope :end_date_in_past, -> { where(end_date: ...Time.zone.now) }
  scope :end_date_in_future, -> { where(end_date: Time.zone.now...) }
  scope :start_date_in_past, -> { where(start_date: ...Time.zone.now) }
  scope :start_date_in_future, -> { where(start_date: Time.zone.now...) }

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

  scope :mentors, -> { joins(:participant_profile).merge(ParticipantProfile.mentors) }
  scope :ects, -> { joins(:participant_profile).merge(ParticipantProfile.ects) }

  scope :for_school, ->(school) { joins(:school).where(school: { id: school.id }) }

  scope :oldest_first, -> { order(created_at: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }

  scope :oldest, -> { oldest_first.first }

  def self.latest
    newest_first.first
  end

  # NOTE: these will return nil if the partnership is challenged
  delegate :lead_provider_name, to: :induction_programme
  delegate :delivery_partner_name, to: :induction_programme
  delegate :full_name, to: :participant_profile, allow_nil: true, prefix: :participant
  delegate :full_name, to: :mentor, allow_nil: true, prefix: true
  delegate :email, to: :preferred_identity, allow_nil: true, prefix: "participant"
  delegate :name, :urn, to: :school, prefix: true
  delegate :name, to: :appropriate_body, allow_nil: true, prefix: true
  delegate :schedule_identifier, to: :schedule, allow_nil: true
  delegate :training_programme, to: :induction_programme
  delegate :type, to: :participant_profile, allow_nil: true, prefix: :participant
  delegate :start_year, to: :cohort, prefix: true

  after_save :update_analytics

  def active?
    active_induction_status? && (unknown_end? || end_date_set_in_future?) && !transferring_in?
  end

  def claimed_by_another_school?
    leaving_induction_status? && !school_transfer && end_date_set_in_future?
  end

  def end_date_set_in_future?
    end_date > Time.current
  end

  def unknown_end?
    end_date.nil?
  end

  def enrolled_in_fip?
    induction_programme.full_induction_programme?
  end

  def enrolled_in_cip?
    induction_programme.core_induction_programme?
  end

  def changing!(date_of_change = Time.zone.now)
    update!(induction_status: :changed, end_date: date_of_change)
  end

  def withdrawing!(date_of_change = Time.zone.now)
    update!(induction_status: :withdrawn, end_date: date_of_change)
  end

  def leaving!(date_of_change = Time.zone.now, transferring_out: false)
    # set transferring_out to true if this action originates from the school the participant is leaving
    update!(induction_status: :leaving, end_date: date_of_change, school_transfer: transferring_out)
  end

  def matches_school_appropriate_body?
    appropriate_body_id == school_cohort.appropriate_body_id
  end

  def transferring_in?
    active_induction_status? && start_date > Time.zone.now && school_transfer
  end

  def transferring_out?
    leaving_induction_status? && end_date.present? && end_date > Time.zone.now && school_transfer
  end

  def transferred?
    leaving_induction_status? && end_date.present? && end_date < Time.zone.now
  end

private

  def update_analytics
    Analytics::UpsertECFInductionJob.perform_later(induction_record: self) if saved_changes?
  end
end
