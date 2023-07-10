# frozen_string_literal: true

class Partnership < ApplicationRecord
  has_paper_trail

  CHALLENGE_PERIOD_SINCE_ACADEMIC_YEAR_START = 2.months

  enum challenge_reason: {
    another_provider: "another_provider",
    not_confirmed: "not_confirmed",
    do_not_recognise: "do_not_recognise",
    no_ects: "no_ects",
    mistake: "mistake",
  }

  belongs_to :school, touch: true
  belongs_to :lead_provider
  belongs_to :cohort
  belongs_to :delivery_partner
  has_many :partnership_notification_emails, dependent: :destroy
  has_many :event_logs, as: :owner

  after_save do |partnership|
    unless partnership.saved_changes.empty?
      school.ecf_participant_profiles.touch_all
      school.ecf_participants.touch_all
    end
  end

  after_save :update_analytics

  scope :in_year, ->(year) { joins(:cohort).where(cohort: { start_year: year }) }
  scope :unchallenged, -> { where(challenged_at: nil, challenge_reason: nil) }
  scope :active, -> { unchallenged.where(pending: false) }
  scope :relationships, -> { where(relationship: true) }

  delegate :name, to: :lead_provider, allow_nil: true, prefix: true
  delegate :name, to: :delivery_partner, allow_nil: true, prefix: true

  def self.ransackable_attributes(_auth_object = nil)
    []
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[lead_provider school delivery_partner]
  end

  def challenged?
    challenge_reason.present?
  end

  # NOTE: challenge! has been moved to a service Partnerships::Challenge as there
  # are now many side affects that need to be considered.

  def in_challenge_window?
    return false if challenge_deadline.blank?

    challenge_deadline > Time.zone.now
  end

  def active?
    challenged_at.nil? && challenge_reason.nil? && pending == false
  end

  def unchallenge!
    update!(challenged_at: nil, challenge_reason: nil, challenge_deadline: cohort_challenge_deadline)
  end

private

  def cohort_challenge_deadline
    cohort.academic_year_start_date + CHALLENGE_PERIOD_SINCE_ACADEMIC_YEAR_START
  end

  def update_analytics
    Analytics::UpsertECFPartnershipJob.perform_later(partnership: self) if saved_changes?
  end
end
