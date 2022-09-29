# frozen_string_literal: true

class AddMonthlyServiceFeeToContracts < ActiveRecord::Migration[6.1]
  def change
    add_column :call_off_contracts, :monthly_service_fee, :decimal
  end
end
