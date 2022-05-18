# frozen_string_literal: true

class Finance::StatementLineItem < ApplicationRecord
  self.table_name = "statement_line_items"

  belongs_to :statement
  belongs_to :participant_declaration
end
