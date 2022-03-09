# frozen_string_literal: true

class NPQLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :npq_applications
  has_many :npq_participant_profiles, through: :npq_applications, source: :profile
  has_many :npq_participants, through: :npq_participant_profiles, source: :user
  has_many :npq_contracts
  has_many :statements, through: :cpd_lead_provider, class_name: "Finance::Statement::NPQ", source: :npq_statements
  has_one :payable_statement, through: :cpd_lead_provider, class_name: "Finance::Statement::NPQ::Payable"
  has_one :current_statement, -> { current }, through: :cpd_lead_provider, class_name: "Finance::Statement::NPQ", source: :npq_statements
end
