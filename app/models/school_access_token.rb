# frozen_string_literal: true

class SchoolAccessToken < ApplicationRecord
  VALID_FOR = 21.days

  belongs_to :school
  validates :permitted_actions, presence: true
  before_create :generate_token, :set_expiry_date

  def expired?
    expires_at < Time.zone.now
  end

  def permits?(action)
    permitted_actions.include?(action.to_sym)
  end

  def permitted_actions
    super.map(&:to_sym)
  end

private

  def generate_token
    self.token ||= SecureRandom.hex(16) while token.nil? || self.class.exists?(token: token)
  end

  def set_expiry_date
    self.expires_at ||= VALID_FOR.from_now
  end
end
