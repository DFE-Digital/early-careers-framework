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
  # optional while the data is setup
  # enables a different identity/email to be used for this induction
  # rather that the one tied to the participant_profile
  # This is needed to allow us to display the right email in the dashboard
  # and to enable participants transferring between schools (where they might be added with
  # a different email address) to still appear correctly at their old and new schools
  # and still be able to access CIP materials while moving
  belongs_to :preferred_identity, class_name: "ParticipantIdentity", optional: true

  validates :start_date, presence: true

  attr_accessor :force_training_status_change

  validate :cannot_resume_from_withdrawn, unless: :force_training_status_change

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

  scope :active, -> { active_induction_status.where("(end_date IS NULL OR end_date > ?) AND (start_date < ? OR school_transfer=false)", Time.zone.now, Time.zone.now) }
  scope :current, -> { active.or(sit_unknown_transferring_out) }
  scope :transferring_in, -> { active_induction_status.where("start_date > ? AND school_transfer=true", Time.zone.now) }
  scope :transferring_out, -> { leaving_induction_status.where("end_date > ? AND school_transfer=true", Time.zone.now) }
  scope :sit_unknown_transferring_out, -> { leaving_induction_status.where("end_date > ? AND school_transfer=false", Time.zone.now) }
  scope :transferred, -> { leaving_induction_status.where("end_date < ?", Time.zone.now) }
  scope :mentors, -> { joins(:participant_profile).where(participant_profiles: { type: "ParticipantProfile::Mentor" }) }
  scope :ects, -> { joins(:participant_profile).where(participant_profiles: { type: "ParticipantProfile::ECT" }) }

  scope :for_school, ->(school) { joins(:school).where(school: { id: school.id }) }

  def self.latest
    order(created_at: :asc).last
  end

  delegate :lead_provider, to: :induction_programme, allow_nil: true
  delegate :lead_provider_name, to: :induction_programme, allow_nil: true

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

  def leaving!(date_of_change = Time.zone.now)
    update!(induction_status: :leaving, end_date: date_of_change)
  end

  def transferring_in?
    active_induction_status? && start_date > Time.zone.now
  end

  def transferring_out?
    leaving_induction_status? && end_date.present? && end_date > Time.zone.now && school_transfer
  end

  def transferred?
    leaving_induction_status? && end_date.present? && end_date < Time.zone.now
  end

  def cannot_resume_from_withdrawn
    errors.add(:base, I18n.t(:invalid_resume)) if training_status_changed?(from: "withdrawn", to: "active")
    errors.add(:base, I18n.t(:invalid_resume)) if training_status_changed?(from: "withdrawn", to: "deferred")
  end
end
