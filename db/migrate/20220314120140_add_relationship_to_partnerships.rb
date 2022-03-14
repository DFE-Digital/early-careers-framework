# frozen_string_literal: true

class AddRelationshipToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :relationship, :boolean, null: false, default: false
  end
end
