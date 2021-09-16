class AddPercentagesToBand < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_bands, :output_payment_percantage, :integer, default: 60
    add_column :participant_bands, :service_fee_percentage, :integer, default: 40
  end
end
