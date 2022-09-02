# frozen_string_literal: true

class Finance::StatementLineItem < ApplicationRecord
  self.table_name = "statement_line_items"

  BILLABLE_STATES = %w[eligible payable paid].freeze
  REFUNDABLE_STATES = %w[awaiting_clawback clawed_back].freeze

  belongs_to :statement
  belongs_to :participant_declaration

  scope :billable, -> { eligible.or(payable).or(paid) }
  scope :refundable, -> { awaiting_clawback.or(clawed_back) }

  enum state: {
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
    ineligible: "ineligible",
    awaiting_clawback: "awaiting_clawback",
    clawed_back: "clawed_back",
  }

  validate :validate_single_billable_relationship, on: [:create]
  validate :validate_single_refundable_relationship, on: [:create]

  def billable?
    BILLABLE_STATES.include?(state)
  end

  def refundable?
    REFUNDABLE_STATES.include?(state)
  end

private

  def validate_single_billable_relationship
    if billable? && Finance::StatementLineItem
      .where(participant_declaration:)
      .billable
      .exists?
      errors.add(:participant_declaration, "is already asscociated to another statement as a billable")
    end
  end

  def validate_single_refundable_relationship
    if refundable? && Finance::StatementLineItem
      .where(participant_declaration:)
      .refundable
      .exists?
      errors.add(:participant_declaration, "is already asscociated to another statement as a refundable")
    end
  end
end
