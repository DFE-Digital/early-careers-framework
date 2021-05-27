# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable, :passwordless_authenticatable
  has_paper_trail

  has_one :induction_coordinator_profile, dependent: :destroy
  has_many :schools, through: :induction_coordinator_profile
  has_one :lead_provider_profile, dependent: :destroy
  has_one :lead_provider, through: :lead_provider_profile
  has_one :admin_profile, dependent: :destroy
  has_one :early_career_teacher_profile, dependent: :destroy
  has_one :mentor_profile, dependent: :destroy

  validates :full_name, presence: true
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

  def mentor?
    mentor_profile.present?
  end

  def core_induction_programme
    return early_career_teacher_profile.core_induction_programme if early_career_teacher?
    return mentor_profile.core_induction_programme if mentor?
  end

  scope :induction_coordinators, -> { joins(:induction_coordinator_profile) }
  scope :for_lead_provider, -> { includes(:lead_provider).joins(:lead_provider) }
  scope :admins, -> { joins(:admin_profile) }
  scope :early_career_teachers, -> { joins(:early_career_teacher_profile).includes(:early_career_teacher_profile) }

  scope :changed_since, lambda { |timestamp|
    if timestamp.present?
      where("updated_at > ?", timestamp)
    else
      where("updated_at is not null")
    end.order(:updated_at, :id)
  }
end
