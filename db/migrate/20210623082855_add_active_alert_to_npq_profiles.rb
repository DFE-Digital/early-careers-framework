# frozen_string_literal: true

class AddActiveAlertToNPQProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_profiles, :active_alert, :boolean, default: false
  end
end
