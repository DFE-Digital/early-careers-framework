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
  validates :email, presence: true, uniqueness: true, notify_email: true

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
  scope :early_career_teachers, -> { joins(:early_career_teacher_profile).includes(:early_career_teacher_profile) }
  scope :mentors, -> { joins(:mentor_profile).includes(:mentor_profile) }

  scope :changed_since, lambda { |timestamp|
    if timestamp.present?
      where("updated_at > ?", timestamp)
    else
      where("updated_at is not null")
    end.order(:updated_at, :id)
  }

  scope :includes_school, lambda {
    includes(early_career_teacher_profile: %i[cohort school], mentor_profile: %i[cohort school])
  }

  scope :is_participant, lambda {
    includes_school.where.not(early_career_teacher_profile: { id: nil }).or(User.where.not(mentor_profile: { id: nil }))
  }

  scope :in_school, lambda { |school_id|
    includes_school.where(early_career_teacher_profile: { school_id: school_id }).or(User.where(mentor_profile: { school_id: school_id }))
  }
end
