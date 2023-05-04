# frozen_string_literal: true

class DeliveryPartner < DiscardableRecord
  has_paper_trail

  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships
  has_many :partnership_csv_uploads

  has_many :partnerships
  has_many :active_partnerships, -> { active }, class_name: "Partnership"
  has_many :schools, through: :active_partnerships

  has_many :training_record_states, inverse_of: :delivery_partner

  has_many :ecf_participant_profiles, through: :schools, class_name: "ParticipantProfile"
  has_many :ecf_participants, through: :ecf_participant_profiles, source: :user
  has_many :active_ecf_participant_profiles, through: :schools
  has_many :active_ecf_participants, through: :active_ecf_participant_profiles, source: :user

  has_many :delivery_partner_profiles, dependent: :destroy
  has_many :users, through: :delivery_partner_profiles

  scope :name_order, -> { order("UPPER(name)") }

  after_discard do
    provider_relationships.discard_all
  end

  def cohorts_with_provider(lead_provider)
    provider_relationships.joins(:cohort).includes(:cohort).where(lead_provider:).map(&:cohort)
  end
end
