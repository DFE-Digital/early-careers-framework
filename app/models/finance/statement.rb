# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  include Finance::ECFPaymentsHelper

  self.table_name = "statements"

  belongs_to :cpd_lead_provider
  belongs_to :cohort
  has_many :participant_declarations
  scope :payable,      -> { where("deadline_date < DATE(NOW()) AND payment_date >= DATE(NOW())") }
  scope :closed,       -> { where("payment_date < ?", Date.current) }
  scope :current,      -> { where("deadline_date >= DATE(NOW())") }
  scope :latest,       -> { order(deadline_date: :asc).last }
  scope :upto_current, -> { payable.or(closed).or(current) }
  scope :output,       -> { where(output_fee: true) }

  class << self
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
