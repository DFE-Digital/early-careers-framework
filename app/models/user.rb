# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  devise :registerable, :trackable, :passwordless_authenticatable

  has_many :participant_identities

  has_one :induction_coordinator_profile, dependent: :destroy
  has_many :schools, through: :induction_coordinator_profile

  has_one :lead_provider_profile, dependent: :destroy
  has_one :lead_provider, through: :lead_provider_profile
  has_one :admin_profile, dependent: :destroy
  has_one :finance_profile, dependent: :destroy

  has_one :teacher_profile, dependent: :destroy

  has_many :delivery_partner_profiles, dependent: :destroy
  has_many :delivery_partners, through: :delivery_partner_profiles

  has_many :appropriate_body_profiles, dependent: :destroy
  has_many :appropriate_bodies, through: :appropriate_body_profiles

  has_many :mentee_participant_declarations, class_name: "ParticipantDeclaration", foreign_key: :mentor_user_id

  # TODO: Legacy associations, to be removed
  has_many :participant_profiles, through: :teacher_profile
  has_one :early_career_teacher_profile, through: :teacher_profile
  has_one :mentor_profile, through: :teacher_profile

  has_many :npq_profiles, through: :teacher_profile
  # end: TODO

  has_many :npq_application_eligibility_imports, class_name: "NPQApplications::EligibilityImport"
  has_many :npq_application_exports, class_name: "NPQApplications::Export"

  before_validation :strip_whitespace
  after_update :sync_email_with_identity

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, notify_email: true
  validates :get_an_identity_id, uniqueness: { allow_blank: true }
  validates :get_an_identity_id,
            inclusion: {
              in: ->(user) { [user.get_an_identity_id_was] },
              message: "cannot be changed once set",
            },
            on: :update,
            if: -> { get_an_identity_id_was.present? }

  self.filter_attributes += %i[email full_name]

  def self.ransackable_attributes(_auth_object = nil)
    %w[id full_name email]
  end

  # changed from has_many :npq_applications as these now live on participant_identities
  # and it is possible that there are applications on one or more of the user's
  # participant_identity records
  def npq_applications
    NPQApplication.joins(:participant_identity).where(participant_identity: { user_id: id })
  end

  def admin?
    admin_profile.present?
  end

  def finance?
    finance_profile.present?
  end

  def delivery_partner?
    delivery_partner_profiles.any?
  end

  def appropriate_body?
    appropriate_body_profiles.any?
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

  def teacher?
    teacher_profile.present?
  end

  def mentor?
    mentor_profile.present?
  end

  def npq?
    npq_profiles.any?(&:active_record?)
  end

  def npq_registered?
    npq? || npq_applications.any?
  end

  def participant?
    early_career_teacher? || mentor?
  end

  def induction_coordinator_and_mentor?
    induction_coordinator? && mentor?
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
    elsif delivery_partner?
      "Delivery partner"
    elsif appropriate_body?
      "Appropriate body"
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

  def user_roles
    @user_roles ||= [
      ("appropriate_body" if appropriate_body?),
      ("delivery_partner" if delivery_partner?),
      ("admin" if admin?),
      ("finance" if finance?),
      ("induction_coordinator" if induction_coordinator?),
      ("induction_coordinator_and_mentor" if induction_coordinator_and_mentor?),
      ("teacher" if teacher?),
    ].compact
  end

  def school
    return early_career_teacher_profile.school if early_career_teacher?
    return mentor_profile.school if mentor?
    return induction_coordinator_profile.schools.first if induction_coordinator?
  end

  scope :name_order, -> { order("UPPER(full_name)") }
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
    joins(:participant_profiles).merge(ParticipantProfile.ecf.active_record).includes(mentor_profile: :school_cohort, early_career_teacher_profile: :school_cohort)
  }

  scope :is_participant, lambda {
    joins(:participant_profiles).merge(ParticipantProfile.active_record)
  }

  def self.full_name_matches(search_term)
    return none if search_term.blank?

    where("users.full_name ilike ?", "%#{search_term}%")
  end

  def self.email_matches(search_term)
    return none if search_term.blank?

    where("users.email like ?", "%#{search_term}%")
  end

private

  def sync_email_with_identity
    if saved_change_to_email? && participant_identities.count == 1
      participant_identities.original.first&.update!(email:)
    end
  end

  def strip_whitespace
    full_name&.squish!
    email&.squish!
  end
end
