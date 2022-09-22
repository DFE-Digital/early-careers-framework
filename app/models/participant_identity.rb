# frozen_string_literal: true

class ParticipantIdentity < ApplicationRecord
  belongs_to :user, touch: true
  has_many :participant_profiles
  has_many :npq_participant_profiles, class_name: "ParticipantProfile::NPQ"
  has_many :npq_applications
  has_many :induction_records, through: :participant_profiles

  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :external_identifier, uniqueness: true

  enum origin: {
    ecf: "ecf",
    npq: "npq",
  }, _suffix: true

  scope :original, -> { where("participant_identities.external_identifier = participant_identities.user_id") }
  scope :transferred, -> { where("participant_identities.external_identifier != participant_identities.user_id") }
end
