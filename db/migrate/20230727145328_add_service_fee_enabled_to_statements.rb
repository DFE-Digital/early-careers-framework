# frozen_string_literal: true

class AddServiceFeeEnabledToStatements < ActiveRecord::Migration[7.0]
  def change
    add_column :statements, :service_fee_enabled, :boolean, default: true
  end
end
