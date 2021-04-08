# frozen_string_literal: true

class User < ApplicationRecord
  devise :registerable, :trackable, :confirmable, :passwordless_authenticatable

  has_one :induction_coordinator_profile

  has_one :admin_profile

  has_one :early_career_teacher_profile

  has_one :mentor_profile

  has_one :core_induction_programme, through: :early_career_teacher_profile

  validates :full_name, presence: { message: "Enter your full name" }
  validates :email, presence: true, uniqueness: true, format: { with: Devise.email_regexp }

  def admin?
    admin_profile.present?
  end

  def induction_coordinator?
    induction_coordinator_profile.present?
  end

  def early_career_teacher?
    early_career_teacher_profile.present?
  end

  def mentor?
    mentor_profile.present?
  end

  def course_years
    core_induction_programme&.course_years || []
  end
end
