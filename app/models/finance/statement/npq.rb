# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement
  has_one :npq_lead_provider, through: :cpd_lead_provider

  def payable!
    update!(type: "Finance::Statement::NPQ::Payable")
  end
end

require "finance/statement/npq/payable"
require "finance/statement/npq/paid"
