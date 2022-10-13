# frozen_string_literal: true

class Partnership < ApplicationRecord
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

  has_paper_trail

  after_save do |partnership|
    unless partnership.saved_changes.empty?
      school.ecf_participant_profiles.touch_all
      school.ecf_participants.touch_all
    end
  end

  after_save :update_analytics

  def challenged?
    challenge_reason.present?
  end

  scope :in_year, ->(year) { joins(:cohort).where(cohort: { start_year: year }) }
  scope :unchallenged, -> { where(challenged_at: nil, challenge_reason: nil) }
  scope :active, -> { unchallenged.where(pending: false) }
  scope :relationships, -> { where(relationship: true) }

  delegate :name, to: :lead_provider, allow_nil: true, prefix: true

  # NOTE: challenge! has been moved to a service Partnerships::Challenge as there
  # are now many side affects that need to be considered.

  def in_challenge_window?
    return false if challenge_deadline.blank?

    challenge_deadline > Time.zone.now
  end

  def active?
    challenged_at.nil? && challenge_reason.nil? && pending == false
  end

private

  def update_analytics
    Analytics::UpsertECFPartnershipJob.perform_later(partnership: self) if saved_changes?
  end
end
