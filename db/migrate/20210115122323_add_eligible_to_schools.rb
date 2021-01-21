# frozen_string_literal: true

class AddEligibleToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :eligible, :boolean, null: false, default: true
  end
end
