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
  scope :secondary, -> { where("participant_identities.external_identifier != participant_identities.user_id") }

  def self.email_matches(search_term)
    return none if search_term.blank?

    where("participant_identities.email like ?", "%#{search_term}%")
  end

  # The original identity of the participant
  def original_identity?
    external_identifier == user_id
  end

  # Any other identity than the original
  def secondary_identity?
    !original_identity?
  end

  # Most likely identity of de-duped user
  def transferred_identity?
    secondary_identity? && participant_profiles.any?
  end

  # Just another identity for the same user
  def additional_identity?
    secondary_identity? && participant_profiles.blank?
  end
end
