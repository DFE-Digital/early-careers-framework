# frozen_string_literal: true

class AddNPQMonthlyServiceFee < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_contracts, :monthly_service_fee, :decimal
  end
end
