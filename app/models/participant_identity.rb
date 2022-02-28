# frozen_string_literal: true

class ParticipantIdentity < ApplicationRecord
  self.table_name = "identities"

  belongs_to :user
  has_many :participant_profiles
  has_many :npq_applications

  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :external_identifier, uniqueness: true

  enum origin: {
    ecf: "ecf",
    npq: "npq",
  }, _suffix: true

  scope :original, -> { where("identities.external_identifier = identities.user_id") }
  scope :transferred, -> { where("identities.external_identifier != identities.user_id") }
end
