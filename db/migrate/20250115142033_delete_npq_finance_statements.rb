# frozen_string_literal: true

class DeleteNPQFinanceStatements < ActiveRecord::Migration[7.1]
  def up
    statement_types = [
      "Finance::Statement::NPQ",
      "Finance::Statement::NPQ::Payable",
      "Finance::Statement::NPQ::Paid",
    ]

    Finance::StatementLineItem.includes(:statement).where(statement: { type: statement_types }).in_batches(of: 10_000) { |batch| batch.delete_all }
    Finance::Adjustment.includes(:statement).where(statement: { type: statement_types }).in_batches(of: 10_000) { |batch| batch.delete_all }
    Finance::Statement.where(type: statement_types).in_batches(of: 10_000) { |batch| batch.delete_all }
  end
end
