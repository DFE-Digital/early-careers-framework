# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  validate :activation, if: -> { active? }
  validate :withdrawal, if: -> { withdrawn? }
  validate :deferral,   if: -> { deferred? }

  belongs_to :participant_profile
  enum state: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }

private

  def withdrawal
    return unless current_state

    errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.state == self.class.states[:withdrawn]
  end

  def activation
    return unless current_state

    errors.add(:base, I18n.t(:already_active)) if current_state.state == self.class.states[:active]
    errors.add(:base, I18n.t(:invalid_resume)) if current_state.state == self.class.states[:withdrawn]
  end

  def deferral
    return unless current_state

    errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.state == self.class.states[:withdrawn]
    errors.add(:base, I18n.t(:invalid_deferral)) if current_state.state == self.class.states[:deferred]
  end

  def current_state
    participant_profile.participant_profile_state
  end
end
