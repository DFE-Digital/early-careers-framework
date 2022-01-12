# frozen_string_literal: true

class ParticipantIdentity < ApplicationRecord
  belongs_to :user
  has_many :participant_profiles
  has_many :npq_applications

  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :external_identifier, uniqueness: true

  enum origin: {
    ecf: "ecf",
    npq: "npq",
  }, _suffix: true

  scope :original, -> { where("participant_identities.external_identifier = participant_identities.user_id") }
  scope :transferred, -> { where("participant_identities.external_identifier != participant_identities.user_id") }
end
