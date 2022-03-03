# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  include FinanceHelper

  self.table_name = "statements"

  belongs_to :cpd_lead_provider

  has_many :participant_declarations
  scope :payable, -> { where("deadline_date < DATE(NOW()) AND payment_date >= DATE(NOW())") }
  scope :closed,  -> { where("payment_date < ?", Date.current) }
  scope :current, -> { where("deadline_date >= DATE(NOW())") }
  scope :latest, -> { order(deadline_date: :asc).last }
  scope :upto_current, -> { payable.or(closed).or(current) }

  def past_deadline_date?
    participant_declarations.any?
  end

  def current?
    payment_date > Time.current && deadline_date > Time.current
  end

  def to_param
    name.downcase.gsub(" ", "-")
  end

  # def declarations
  #   if current?
  #     participant_declarations
  #       .for_course_identifier(contract.course_identifier)
  #       .unique_paid_payable_or_eligible.count
  #   else
  #     participant_declarations
  #       .for_course_identifier(contract.course_identifier)
  #       .where.not(status: "voided")
  #   end
  # end
end

require "finance/statement/ecf"
require "finance/statement/npq"
