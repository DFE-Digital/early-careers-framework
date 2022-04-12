# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement
  has_one :npq_lead_provider, through: :cpd_lead_provider
  has_many :participant_declarations, -> { not_voided.not_ineligible }, foreign_key: :statement_id
end

require "finance/statement/npq/payable"
require "finance/statement/npq/paid"
