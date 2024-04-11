# frozen_string_literal: true

class AddFundingCapToNPQContracts < ActiveRecord::Migration[7.1]
  def change
    add_column :npq_contracts, :funding_cap, :integer
  end
end
