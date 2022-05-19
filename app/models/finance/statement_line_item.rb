# frozen_string_literal: true

class Finance::StatementLineItem < ApplicationRecord
  self.table_name = "statement_line_items"

  belongs_to :statement
  belongs_to :participant_declaration

  scope :eligible, -> { where(state: "eligible") }
  scope :payable, -> { where(state: "payable") }
  scope :paid, -> { where(state: "paid") }
  scope :voided, -> { where(state: "voided") }
end
