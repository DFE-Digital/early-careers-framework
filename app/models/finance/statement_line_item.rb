# frozen_string_literal: true

class Finance::StatementLineItem < ApplicationRecord
  self.table_name = "statement_line_items"

  belongs_to :statement
  belongs_to :participant_declaration

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
    ineligible: "ineligible",
  }
end
