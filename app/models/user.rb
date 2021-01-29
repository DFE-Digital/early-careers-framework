# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :rememberable, :validatable, :confirmable, :passwordless_authenticatable
  has_one :induction_coordinator_profile
  has_one :lead_provider_profile
  has_one :admin_profile
  has_one :lead_provider, through: :lead_provider_profile

  validates :full_name, presence: { message: "Enter your full name" }
  validates :email, presence: true

  def admin?
    admin_profile.present?
  end

  def induction_coordinator?
    induction_coordinator_profile.present?
  end

  def password_required?
    false
  end
end
