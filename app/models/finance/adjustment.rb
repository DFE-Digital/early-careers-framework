# frozen_string_literal: true

class Finance::Adjustment < ApplicationRecord
  has_paper_trail

  self.table_name = "finance_adjustments"

  belongs_to :statement

  validates :payment_type, presence: true
end
