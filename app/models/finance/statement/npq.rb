# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement
  has_one :npq_lead_provider, through: :cpd_lead_provider

  STATEMENT_TYPE = "npq"

  def payable!
    update!(type: "Finance::Statement::NPQ::Payable")
  end

  def previous_statements
    Finance::Statement::NPQ
      .where(cohort:)
      .where(cpd_lead_provider:)
      .where("payment_date < ?", payment_date)
  end

  def paid!
    update!(type: "Finance::Statement::NPQ::Paid")
  end
end

require "finance/statement/npq/payable"
require "finance/statement/npq/paid"
