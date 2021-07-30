# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable, :passwordless_authenticatable
  has_paper_trail

  has_one :induction_coordinator_profile, dependent: :destroy
  has_many :schools, through: :induction_coordinator_profile

  has_one :lead_provider_profile, dependent: :destroy
  has_one :lead_provider, through: :lead_provider_profile
  has_one :admin_profile, dependent: :destroy
  has_one :finance_profile, dependent: :destroy

  has_one :teacher_profile, dependent: :destroy

  # TODO: Legacy associations, to be removed
  has_many :participant_profiles, through: :teacher_profile
  has_one :early_career_teacher_profile, through: :teacher_profile
  has_one :mentor_profile, through: :teacher_profile

  has_many :npq_profiles, through: :teacher_profile
  # end: TODO

  before_validation :strip_whitespace

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, notify_email: true

  def admin?
    admin_profile.present?
  end

  def finance?
    finance_profile.present?
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

  def npq?
    npq_profiles.any?(&:active?)
  end

  def participant?
    early_career_teacher? || mentor?
  end

  def core_induction_programme
    return early_career_teacher_profile.core_induction_programme if early_career_teacher?
    return mentor_profile.core_induction_programme if mentor?
  end

  def user_description
    if admin?
      "DfE admin"
    elsif induction_coordinator?
      "Induction tutor"
    elsif finance?
      "DfE Finance"
    elsif lead_provider?
      "Lead provider"
    elsif early_career_teacher?
      "Early career teacher"
    elsif mentor?
      "Mentor"
    else
      "Unknown"
    end
  end

  def cohort
    return early_career_teacher_profile.cohort if early_career_teacher?
    return mentor_profile.cohort if mentor?
  end

  def school
    return early_career_teacher_profile.school if early_career_teacher?
    return mentor_profile.school if mentor?
    return induction_coordinator_profile.schools.first if induction_coordinator?
  end

  scope :induction_coordinators, -> { joins(:induction_coordinator_profile) }
  scope :for_lead_provider, -> { includes(:lead_provider).joins(:lead_provider) }
  scope :admins, -> { joins(:admin_profile) }
  scope :finance_users, -> { joins(:finance_profile) }

  scope :changed_since, lambda { |timestamp|
    if timestamp.present?
      where("users.updated_at > ?", timestamp)
    else
      where("users.updated_at is not null")
    end.order(:updated_at, :id)
  }

  scope :is_ecf_participant, lambda {
    joins(:participant_profiles).merge(ParticipantProfile.ecf.active).includes(mentor_profile: :school_cohort, early_career_teacher_profile: :school_cohort)
  }

  scope :is_participant, lambda {
    joins(:participant_profiles).merge(ParticipantProfile.active)
  }

private

  def strip_whitespace
    full_name&.squish!
    email&.squish!
  end
end
