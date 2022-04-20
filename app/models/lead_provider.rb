# frozen_string_literal: true

# This is actually ECFLeadProvider in all but name. See https://github.com/DFE-Digital/early-careers-framework/issues/698
class LeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :participant_declarations, through: :cpd_lead_provider, class_name: "ParticipantDeclaration::ECF"

  has_many :partnerships
  has_many :active_partnerships, -> { active }, class_name: "Partnership"
  has_many :schools, through: :active_partnerships

  has_many :ecf_participant_profiles, through: :schools, class_name: "ParticipantProfile::ECF"
  has_many :ecf_participants, through: :ecf_participant_profiles, source: :user
  has_many :active_ecf_participant_profiles, through: :schools
  has_many :active_ecf_participants, through: :active_ecf_participant_profiles, source: :user

  has_many :lead_provider_profiles
  has_many :users, through: :lead_provider_profiles
  has_many :provider_relationships
  has_many :delivery_partners, through: :provider_relationships
  has_and_belongs_to_many :cohorts
  has_many :lead_provider_cips
  has_many :core_induction_programmes, through: :lead_provider_cips
  has_many :partnership_csv_uploads
  has_many :lead_provider_api_tokens
  has_one :call_off_contract

  has_many :statements, through: :cpd_lead_provider, class_name: "Finance::Statement::ECF", source: :ecf_statements
  validates :name, presence: { message: "Enter a name" }

  def next_output_fee_statement
    statements.next_output_fee_statements.first
  end
end
