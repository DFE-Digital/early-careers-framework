# frozen_string_literal: true

class NPQContract < ApplicationRecord
  belongs_to :npq_lead_provider
  validates_numericality_of :number_of_payment_periods, :output_payment_percentage, :service_fee_installments, :service_fee_percentage, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :per_participant, greater_than: 0
  validates_numericality_of :recruitment_target, only_integer: true, greater_than: 0
end
