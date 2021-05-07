# frozen_string_literal: true

class BasePartnership < ApplicationRecord
  self.abstract_class = true

  CHALLENGE_WINDOW = 14.days.freeze

  before_create :set_challenge_deadline

  belongs_to :school
  belongs_to :lead_provider
  belongs_to :cohort
  belongs_to :delivery_partner
  has_many :partnership_notification_emails, as: :partnerable

  has_paper_trail

  def in_challenge_window?
    challenge_deadline > Time.zone.now
  end

protected

  def set_challenge_deadline
    self.challenge_deadline ||= Time.zone.now + CHALLENGE_WINDOW
  end
end
