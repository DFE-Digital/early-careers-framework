# frozen_string_literal: true

class LeadProvider < ApplicationRecord
  has_many :partnerships
  has_many :schools, through: :partnerships
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
