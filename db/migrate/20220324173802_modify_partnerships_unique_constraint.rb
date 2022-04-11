# frozen_string_literal: true

class ModifyPartnershipsUniqueConstraint < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :partnerships, %i[school_id lead_provider_id cohort_id], name: "unique_partnerships", unique: true
    add_index :partnerships, %i[school_id lead_provider_id delivery_partner_id cohort_id], name: "unique_partnerships", unique: true, algorithm: :concurrently
  end
end
