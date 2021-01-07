# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :rememberable, :validatable, :confirmable, :passwordless_authenticatable
  has_one :induction_coordinator_profile
  has_one :lead_provider_profile
  has_one :admin_profile

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def password_required?
    false
  end
end
