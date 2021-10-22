class NPQContract < ApplicationRecord
  def monthly_service_fee
    recruitment_target * per_participant * service_fee_percentage / service_fee_installments
  end

  def paid_milestone_output_payment_basis
    per_participant / number_of_payment_periods
  end
end
