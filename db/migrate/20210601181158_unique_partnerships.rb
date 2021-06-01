# frozen_string_literal: true

class UniquePartnerships < ActiveRecord::Migration[6.1]
  def change
    add_index :partnerships, %i[school_id lead_provider_id cohort_id], unique: true, name: "unique_partnerships"
  end
end
