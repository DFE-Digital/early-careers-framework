# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement
  has_one :lead_provider, through: :cpd_lead_provider

  def contract
    CallOffContract.find_by!(
      version: contract_version,
      cohort:,
      lead_provider:,
    )
  end

  def payable!
    update!(type: "Finance::Statement::ECF::Payable")
  end

  def calculator
    @calculator ||= Finance::ECF::StatementCalculator.new(statement: self)
  end
end

require "finance/statement/ecf/payable"
require "finance/statement/ecf/paid"
