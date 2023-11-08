# frozen_string_literal: true

class AddRoleToFinanceProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :finance_profiles, :role, :string
  end
end
