# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  include FinanceHelper

  self.table_name = "statements"

  belongs_to :cpd_lead_provider

  has_many :participant_declarations
  scope :payable, -> { where("payment_date >= ?", Date.current).order(payment_date: :asc) }

  def open?
    payment_date > Time.current
  end
end
