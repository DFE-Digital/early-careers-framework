# frozen_string_literal: true

class AddSuperUserFlagToAdminProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_profiles, :super_user, :boolean, default: false
  end
end
