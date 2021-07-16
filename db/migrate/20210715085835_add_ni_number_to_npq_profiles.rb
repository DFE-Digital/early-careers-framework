# frozen_string_literal: true

class AddNiNumberToNPQProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_profiles, :nino, :text, null: true
  end
end
