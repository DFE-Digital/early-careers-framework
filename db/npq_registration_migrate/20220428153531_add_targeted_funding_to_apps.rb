class AddTargetedFundingToApps < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :targeted_support_funding_eligibility, :boolean, default: false
  end
end
