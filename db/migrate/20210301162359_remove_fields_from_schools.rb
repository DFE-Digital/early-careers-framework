# frozen_string_literal: true

class RemoveFieldsFromSchools < ActiveRecord::Migration[6.1]
  def change
    change_table :schools, bulk: true do
      remove_column :schools, :capacity, :integer
      remove_column :schools, :address_line4, :string
      remove_column :schools, :country, :string
      remove_column :schools, :previous_school_urn, :string
    end
  end
end
