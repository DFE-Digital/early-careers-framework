# frozen_string_literal: true

class AddActiveAlertToNpqProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_profiles, :active_alert, :boolean, default: false
  end
end
