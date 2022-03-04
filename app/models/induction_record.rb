# frozen_string_literal: true

class InductionRecord < ApplicationRecord
  has_paper_trail

  belongs_to :induction_programme
  belongs_to :participant_profile
  belongs_to :schedule, class_name: "Finance::Schedule"

  # optional while the data is setup
  # enables a different identity/email to be used for this induction
  # rather that the one tied to the participant_profile
  # This is needed to allow us to display the right email in the dashboard
  # and to enable participants transferring between schools (where they might be added with
  # a different email address) to still appear correctly at their old and new schools
  # and still be able to access CIP materials while moving
  belongs_to :registered_identity, class_name: "ParticipantIdentity", optional: true

  validates :start_date, presence: true

  enum induction_status: {
    active: "active",
    withdrawn: "withdrawn",
    changed: "changed",
    transferred: "transferred",
    completed: "completed",
  }, _suffix: true

  enum training_status: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }, _prefix: "training_status"

  scope :current, -> { active_induction_status.where("start_date < ?", Time.zone.now).or(transferring_out) }
  scope :transferring_in, -> { where("induction_status='active' AND start_date > ?", Time.zone.now) }
  scope :transferring_out, -> { where("induction_status='transferred' AND end_date > ?", Time.zone.now) }

  def changing!(date_of_change = Time.zone.now)
    update!(induction_status: :changed, end_date: date_of_change)
  end

  def withdrawing!(date_of_change = Time.zone.now)
    update!(induction_status: :withdrawn, end_date: date_of_change)
  end

  def transferring!(date_of_change = Time.zone.now)
    update!(induction_status: :transferred, end_date: date_of_change)
  end

  def transferring_in?
    active_induction_status? && start_date > Time.zone.now
  end

  def transferring_out?
    transferred_induction_status? && end_date.present? && end_date > Time.zone.now
  end
end
