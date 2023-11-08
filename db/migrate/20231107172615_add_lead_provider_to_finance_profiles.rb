# frozen_string_literal: true

class AddLeadProviderToFinanceProfiles < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :finance_profiles, :lead_provider, null: true, index: { algorithm: :concurrently }
  end
end
