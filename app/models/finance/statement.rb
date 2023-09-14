# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  has_paper_trail

  self.table_name = "statements"

  belongs_to :cpd_lead_provider
  belongs_to :cohort

  has_many :statement_line_items, class_name: "Finance::StatementLineItem"
  has_many :participant_declarations, through: :statement_line_items

  has_many :billable_statement_line_items,
           -> { where(state: %w[eligible payable paid]) },
           class_name: "Finance::StatementLineItem"

  has_many :billable_participant_declarations,
           class_name: "ParticipantDeclaration",
           through: :billable_statement_line_items,
           source: :participant_declaration

  has_many :refundable_statement_line_items,
           -> { where(state: %w[awaiting_clawback clawed_back]) },
           class_name: "Finance::StatementLineItem"

  has_many :refundable_participant_declarations,
           class_name: "ParticipantDeclaration",
           through: :refundable_statement_line_items,
           source: :participant_declaration

  has_many :adjustments, -> { order(:created_at) }, class_name: "Finance::Adjustment"

  scope :payable,                   -> { where(arel_table[:deadline_date].lt(Date.current).and(arel_table[:payment_date].gteq(Date.current))) }
  scope :closed,                    -> { where(arel_table[:payment_date].lt(Date.current)) }
  scope :with_future_deadline_date, -> { where(arel_table[:deadline_date].gteq(Date.current)) }
  scope :upto_current,              -> { payable.or(closed) }
  scope :latest,                    -> { order(deadline_date: :asc).last }
  scope :upto,                      ->(statement) { where(arel_table[:deadline_date].lt(statement.deadline_date)) }
  scope :output,                    -> { where(output_fee: true) }
  scope :next_output_fee_statements, lambda {
    output
      .where(type: name)
      .order(deadline_date: :asc)
      .where("deadline_date >= ?", Date.current)
  }

  STATEMENT_TYPES = %w[ecf npq].freeze

  class << self
    def current
      with_future_deadline_date.order(deadline_date: :asc).first
    end
  end

  def open?
    true
  end

  def paid?
    false
  end

  def past_deadline_date?
    participant_declarations.any?
  end

  def current?
    payment_date > Time.current && deadline_date > Time.current
  end

  def previous_statements
    self.class
      .where(cohort:)
      .where(cpd_lead_provider:)
      .where("payment_date < ?", payment_date)
  end

  def adjustment_editable?
    output_fee && !paid?
  end

  def ecf?
    false
  end

  def npq?
    false
  end

  def payable?
    false
  end

  def mark_as_paid_visible?
    output_fee && payable? && !marked_as_paid? && deadline_date < Date.current && participant_declarations.any?
  end

  def mark_as_paid!
    update!(marked_as_paid_at: Time.zone.now)
  end

  def marked_as_paid?
    marked_as_paid_at.present?
  end
end

require "finance/statement/ecf"
require "finance/statement/npq"
