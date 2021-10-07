# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  def valid?(_context = nil)
    current_state = participant_profile.participant_profile_state
    return true if current_state.nil?

    # TODO: Add an active profile state to all ECF participants to avoid 'resume' actions with no profile states
    case state
    when "active"
      errors.add(:base, I18n.t(:already_active)) if current_state.active?
      errors.add(:base, I18n.t(:invalid_resume)) if current_state.withdrawn?
    when "withdrawn"
      errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.withdrawn?
    when "deferred"
      errors.add(:base, I18n.t(:invalid_withdrawal)) if current_state.withdrawn?
      errors.add(:base, I18n.t(:invalid_deferral)) if current_state.deferred?
    end
    errors.none?
  end

  belongs_to :participant_profile
  enum state: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }
end
