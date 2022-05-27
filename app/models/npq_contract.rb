# frozen_string_literal: true

class NPQContract < ApplicationRecord
  belongs_to :npq_lead_provider
  belongs_to :cohort
  belongs_to :npq_course, primary_key: :identifier, foreign_key: :course_identifier

  validates :number_of_payment_periods, :output_payment_percentage, :service_fee_installments, :service_fee_percentage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :per_participant, numericality: { greater_than: 0 }
  validates :recruitment_target, numericality: { only_integer: true, greater_than: 0 }
end
