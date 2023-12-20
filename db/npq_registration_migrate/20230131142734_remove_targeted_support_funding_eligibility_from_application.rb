class RemoveTargetedSupportFundingEligibilityFromApplication < ActiveRecord::Migration[6.1]
  # Removing to this being a depracted field in favour of targeted_delivery_funding_eligibility

  def change
    remove_column :applications, :targeted_support_funding_eligibility, type: :string
  end
end
