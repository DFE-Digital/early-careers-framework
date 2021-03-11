# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable, :confirmable, :passwordless_authenticatable

  has_one :induction_coordinator_profile
  has_one :lead_provider_profile
  has_one :lead_provider, through: :lead_provider_profile
  has_one :admin_profile
  has_one :early_career_teacher_profile
  has_one :core_induction_programme, through: :early_career_teacher_profile

  include Discard::Model
  default_scope -> { kept }

  validates :full_name, presence: { message: "Enter a full name" }
  validates :email, presence: true, uniqueness: true, format: { with: Devise.email_regexp }

  def admin?
    admin_profile.present?
  end

  def supplier_name
    lead_provider&.name
  end

  def induction_coordinator?
    induction_coordinator_profile.present?
  end

  def lead_provider?
    lead_provider_profile.present?
  end

  def early_career_teacher?
    early_career_teacher_profile.present?
  end

  scope :induction_coordinators, -> { joins(:induction_coordinator_profile) }
  scope :for_lead_provider, -> { includes(:lead_provider).joins(:lead_provider) }
  scope :admins, -> { joins(:admin_profile) }
end
