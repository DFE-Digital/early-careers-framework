# frozen_string_literal: true

class AddUpliftAndSparsityFlagsToPupilPremiums < ActiveRecord::Migration[6.1]
  def change
    add_column :pupil_premiums, :pupil_premium_incentive, :boolean, null: false, default: false
    add_column :pupil_premiums, :sparsity_incentive, :boolean, null: false, default: false
  end
end
