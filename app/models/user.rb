# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable, :confirmable, :passwordless_authenticatable

  has_one :induction_coordinator_profile

  has_one :lead_provider_profile
  has_one :lead_provider, through: :lead_provider_profile

  has_one :delivery_partner_profile
  has_one :delivery_partner, through: :delivery_partner_profile

  has_one :admin_profile

  has_one :early_career_teacher_profile
  has_one :core_induction_programme, through: :early_career_teacher_profile

  validates :full_name, presence: { message: "Enter your full name" }
  validates :email, presence: true, uniqueness: true, format: { with: Devise.email_regexp }

  def admin?
    admin_profile.present?
  end

  def supplier_name
    lead_provider&.name || delivery_partner&.name
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

  scope :for_lead_provider, -> { joins(:lead_provider) }
  scope :for_delivery_partner, -> { joins(:delivery_partner) }
  scope :with_supplier, -> { includes(:lead_provider, :delivery_partner) }
end
