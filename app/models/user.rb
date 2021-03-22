# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :uuid             not null, primary key
#  confirmation_sent_at    :datetime
#  confirmation_token      :string
#  confirmed_at            :datetime
#  current_sign_in_at      :datetime
#  current_sign_in_ip      :inet
#  discarded_at            :datetime
#  email                   :string           default(""), not null
#  full_name               :string           not null
#  last_sign_in_at         :datetime
#  last_sign_in_ip         :inet
#  login_token             :string
#  login_token_valid_until :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token  (confirmation_token) UNIQUE
#  index_users_on_discarded_at        (discarded_at)
#  index_users_on_email               (email) UNIQUE
#
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

  after_discard do
    induction_coordinator_profile&.discard! unless induction_coordinator_profile&.discarded?
    lead_provider_profile&.discard! unless lead_provider_profile&.discarded?
    admin_profile&.discard! unless admin_profile&.discarded?
  end

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
