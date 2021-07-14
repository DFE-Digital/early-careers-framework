# frozen_string_literal: true

class LeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :partnerships
  has_many :active_partnerships, -> { active }, class_name: "Partnership"
  has_many :schools, through: :active_partnerships
  has_many :participant_profiles, -> { ecf }, through: :schools
  has_many :participants, through: :participant_profiles, source: :user
  has_many :active_participant_profiles, -> { ecf.active }, through: :schools, source: :participant_profiles
  has_many :active_participants, through: :active_participant_profiles, source: :user
  has_many :lead_provider_profiles
  has_many :users, through: :lead_provider_profiles
  has_many :provider_relationships
  has_many :delivery_partners, through: :provider_relationships
  has_and_belongs_to_many :cohorts
  has_many :lead_provider_cips
  has_many :core_induction_programmes, through: :lead_provider_cips
  has_many :partnership_csv_uploads
  has_many :lead_provider_api_tokens
  has_many :participation_records
  has_one :call_off_contract
  has_many :participant_declarations

  validates :name, presence: { message: "Enter a name" }
end
