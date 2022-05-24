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

  scope :billable, -> { where(state: %w[eligible payable paid]) }

  validate :validate_single_billable_relationship, on: [:create]

private

  def validate_single_billable_relationship
    if Finance::StatementLineItem
      .where(participant_declaration: participant_declaration)
      .billable
      .exists?
      errors.add(:participant_declaration, "is already asscociated to another statement as a billable")
    end
  end
end
