# frozen_string_literal: true

class Finance::Adjustment < ApplicationRecord
  has_paper_trail

  self.table_name = "finance_adjustments"

  belongs_to :statement

  before_validation :strip_whitespace
  validates :payment_type, presence: true
  validates :amount, numericality: { other_than: 0.0 }

private

  def strip_whitespace
    payment_type&.squish!
  end
end
