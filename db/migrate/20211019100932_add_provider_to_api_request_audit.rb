# frozen_string_literal: true

class AddProviderToApiRequestAudit < ActiveRecord::Migration[6.1]
  def change
    add_column :api_request_audits, :current_user_class, :string, null: true
    add_column :api_request_audits, :current_user_id, :string, null: true
  end
end
