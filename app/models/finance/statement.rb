# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  include Finance::ECFPaymentsHelper

  self.table_name = "statements"

  belongs_to :cpd_lead_provider
  belongs_to :cohort
  has_many :participant_declarations
  scope :payable,                   -> { where("deadline_date < DATE(NOW()) AND payment_date >= DATE(NOW())") }
  scope :closed,                    -> { where("payment_date < ?", Date.current) }
  scope :with_future_deadline_date, -> { where("deadline_date >= DATE(NOW())") }
  scope :upto_current,              -> { payable.or(closed) }
  scope :latest,                    -> { order(deadline_date: :asc).last }
  scope :upto,                      ->(statement) { where("deadline_date < ?", statement.deadline_date) }
  scope :output,                    -> { where(output_fee: true) }
  scope :next_output_fee_statements, lambda {
    output
      .left_outer_joins(:participant_declarations)
      .where(type: name)
      .order(deadline_date: :asc)
      .where("deadline_date >= ?", Date.current)
  }

  class << self
    def current
      with_future_deadline_date.order(deadline_date: :asc).first
    end

    def attach(participant_declaration)
      statement = statement_for(participant_declaration)
      statement.participant_declarations << participant_declaration
    end

  private

    def statement_for(participant_declaration)
      case participant_declaration
      when ParticipantDeclaration::ECF
        participant_declaration.cpd_lead_provider.lead_provider.next_output_fee_statement
      when ParticipantDeclaration::NPQ
        participant_declaration.cpd_lead_provider.npq_lead_provider.next_output_fee_statement
      end
    end
  end

  def open?
    true
  end

  def past_deadline_date?
    participant_declarations.any?
  end

  def current?
    payment_date > Time.current && deadline_date > Time.current
  end

  def to_param
    name.downcase.gsub(" ", "-")
  end
end

require "finance/statement/ecf"
require "finance/statement/npq"
