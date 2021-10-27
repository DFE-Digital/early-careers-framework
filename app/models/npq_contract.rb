# frozen_string_literal: true

class NPQContract < ApplicationRecord
  belongs_to :npq_lead_provider
  validates_numericality_of :number_of_payment_periods, :output_payment_percentage, :per_participant, :recruitment_target, :service_fee_installments, :service_fee_percentage
end
