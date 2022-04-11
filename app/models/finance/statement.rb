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
  scope :upto,                      -> (statement) { where("deadline_date < ?", statement.deadline_date) }
  scope :output,                    -> { where(output_fee: true) }

  class << self
    def current
      with_future_deadline_date.order(deadline_date: :asc).first
    end

    def next_output_fee_statement
      output.order(deadline_date: :asc).where("deadline_date >= ?", Date.current).first
    end

    def attach(participant_declaration)
      statement = statement_class_for(participant_declaration).next_output_fee_statement
      statement.participant_declarations << participant_declaration
    end

    private

    def statement_class_for(participant_declaration)
      case participant_declaration
      when ParticipantDeclaration::ECF
        ECF
      when ParticipantDeclaration::NPQ
        NPQ
      end
    end
  end

  def declarations
    if paid?
      participant_declarations.paid
    elsif payable?
      participant_declarations.payable
    else
      participant_declarations.where.not(state: %i[voided ineligible])
    end
  end

  def payable?
    deadline_date > Time.current && payment_date < Time.current
  end

  def paid?
    payment_date <= Time.current
  end

  def open?
    deadline_date <= Time.current
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
