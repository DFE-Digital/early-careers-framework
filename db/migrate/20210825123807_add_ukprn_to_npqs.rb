# frozen_string_literal: true

class AddUkprnToNpqs < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_profiles, :school_ukprn, :text, null: true
  end
end
