# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement
  has_one :npq_lead_provider, through: :cpd_lead_provider
end

require "finance/statement/npq/paid"
require "finance/statement/npq/payable"
