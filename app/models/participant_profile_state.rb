# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  # TODO: Add an active profile state to all ECF participants to avoid 'resume' actions with no profile states
  validate :activation, if: -> { active? }
  validate :withdrawal, if: -> { withdrawn? }
  validate :deferral,   if: -> { deferred? }

  belongs_to :participant_profile
  belongs_to :cpd_lead_provider, optional: true

  enum state: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }

private

  def withdrawal
    return unless current_state

    errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.withdrawn?
  end

  def activation
    return unless current_state

    errors.add(:base, I18n.t(:already_active)) if current_state.active?
    errors.add(:base, I18n.t(:invalid_resume)) if current_state.withdrawn?
  end

  def deferral
    return unless current_state

    errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.withdrawn?
    errors.add(:base, I18n.t(:invalid_deferral)) if current_state.deferred?
  end

  def current_state
    participant_profile.participant_profile_state
  end
end
