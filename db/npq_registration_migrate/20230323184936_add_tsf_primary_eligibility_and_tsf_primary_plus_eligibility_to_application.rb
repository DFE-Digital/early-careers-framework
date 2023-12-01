class AddTsfPrimaryEligibilityAndTsfPrimaryPlusEligibilityToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :tsf_primary_eligibility, :boolean, default: false
    add_column :applications, :tsf_primary_plus_eligibility, :boolean, default: false
  end
end
