# frozen_string_literal: true

class ChangeColumnMonthlyServiceFeeForNPQContracts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :npq_contracts, :monthly_service_fee, from: nil, to: 0.0
  end
end
