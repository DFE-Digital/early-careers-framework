# frozen_string_literal: true

class AddUpliftToMentorProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_profiles, :sparsity_uplift, :boolean, null: false, default: false
    add_column :mentor_profiles, :pupil_premium_uplift, :boolean, null: false, default: false
  end
end
