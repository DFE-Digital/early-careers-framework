# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement
  has_one :lead_provider, through: :cpd_lead_provider

  STATEMENT_TYPE = "ecf"

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

  def paid!
    update!(type: "Finance::Statement::ECF::Paid")
  end

  def calculator
    @calculator ||= Finance::ECF::StatementCalculator.new(statement: self)
  end

  def previous_statements
    Finance::Statement::ECF
      .where(cohort:)
      .where(cpd_lead_provider:)
      .where("payment_date < ?", payment_date)
  end
end
