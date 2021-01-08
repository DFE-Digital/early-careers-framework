# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :rememberable, :validatable, :confirmable, :passwordless_authenticatable
  has_one :induction_coordinator_profile
  has_one :lead_provider_profile
  has_one :admin_profile

  validates :first_name, presence: { message: "Enter a first name" }
  validates :last_name, presence: { message: "Enter a last name" }
  validates :email, presence: true

  def password_required?
    false
  end
end
