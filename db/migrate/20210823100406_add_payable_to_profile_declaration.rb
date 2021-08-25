# frozen_string_literal: true

class AddPayableToProfileDeclaration < ActiveRecord::Migration[6.1]
  def change
    add_column :profile_declarations, :payable, :boolean, default: false
  end
end
