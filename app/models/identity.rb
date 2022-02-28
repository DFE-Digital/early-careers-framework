# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user, inverse_of: :identities
  has_many :participant_profiles, foreign_key: :participant_identity_id
  has_many :npq_applications, foreign_key: :participant_identity_id

  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :external_identifier, uniqueness: true

  enum origin: {
    ecf: "ecf",
    npq: "npq",
  }, _suffix: true

  scope :original, -> { where("identities.external_identifier = identities.user_id") }
  scope :transferred, -> { where("identities.external_identifier != identities.user_id") }

  def self.find_user_by(params = {})
    if params.key?(:id)
      id = params[:id]
      find_by(external_identifier: id)&.user || User.find_by(id: id)
    elsif params.key?(:email)
      email = params[:email]
      find_by(email: email)&.user || User.find_by(email: email)
    else
      User.find_by(params)
    end
  end

end
