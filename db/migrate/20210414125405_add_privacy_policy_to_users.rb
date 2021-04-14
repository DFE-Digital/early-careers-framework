# frozen_string_literal: true

class AddPrivacyPolicyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :privacy_policy_acceptance, :json
  end
end
