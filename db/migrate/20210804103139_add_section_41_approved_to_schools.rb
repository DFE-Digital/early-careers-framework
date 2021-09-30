# frozen_string_literal: true

class AddSection41ApprovedToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :section_41_approved, :boolean, null: false, default: false
  end
end
