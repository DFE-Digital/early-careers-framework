# frozen_string_literal: true

class AddDomainsToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :domains, :string, array: true, null: false, default: []
  end
end
