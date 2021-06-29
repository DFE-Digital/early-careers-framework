# frozen_string_literal: true

class AddUpliftToMentorProfile < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:mentor_profiles, bulk: true) do |table|
        table.column :sparsity_uplift, :boolean, null: false, default: false
        table.column :pupil_premium_uplift, :boolean, null: false, default: false
      end
    end
  end
end
