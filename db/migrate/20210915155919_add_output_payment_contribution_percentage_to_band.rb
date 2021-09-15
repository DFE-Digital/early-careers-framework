class AddOutputPaymentContributionPercentageToBand < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_bands, :output_payment_contribution_percantage, :integer, default: 60
  end
end
