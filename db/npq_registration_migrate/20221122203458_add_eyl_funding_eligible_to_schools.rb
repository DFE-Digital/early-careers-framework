class AddEylFundingEligibleToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :eyl_funding_eligible, :boolean, default: false
  end
end
