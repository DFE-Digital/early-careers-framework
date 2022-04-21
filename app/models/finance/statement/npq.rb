# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement
  has_one :npq_lead_provider, through: :cpd_lead_provider
  has_many :participant_declarations,        -> { not_voided.not_ineligible }, foreign_key: :statement_id
  has_many :voided_participant_declarations, -> { voided }, foreign_key: :statement_id, class_name: "ParticipantDeclaration::NPQ"

  def payable!
    update!(type: "Finance::Statement::NPQ::Payable")
  end
end

require "finance/statement/npq/payable"
require "finance/statement/npq/paid"
