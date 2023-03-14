# frozen_string_literal: true

class NPQLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :npq_applications
  has_many :npq_participant_profiles, through: :npq_applications, source: :profile
  has_many :npq_participants, through: :npq_participant_profiles, source: :user
  has_many :npq_contracts
  has_many :cohorts, through: :npq_contracts
  has_many :statements, through: :cpd_lead_provider, class_name: "Finance::Statement::NPQ", source: :npq_statements
  has_many :participant_declarations, class_name: "ParticipantDeclaration::NPQ", through: :cpd_lead_provider

  scope :name_order, -> { order("UPPER(name)") }

  def next_output_fee_statement(cohort)
    statements.next_output_fee_statements.where(cohort:).first
  end
end
