# frozen_string_literal: true

class Identity < ApplicationRecord
  devise :registerable, :trackable, :passwordless_authenticatable

  belongs_to :user, inverse_of: :identities
  has_many :participant_profiles, foreign_key: :participant_identity_id
  has_many :npq_applications, foreign_key: :participant_identity_id

  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :external_identifier, uniqueness: true, if: :external_identifier

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

  def self.find_identity_by(params = {})
    result = if params.key?(:id)
               find_by(external_identifier: params[:id])
             elsif params.key?(:email)
               find_by(email: params[:email])
             end

    result || begin
      user = User.find_by(params)
      user.identities.find_or_create_by!(email: user.email) if user
    end
  end
end
