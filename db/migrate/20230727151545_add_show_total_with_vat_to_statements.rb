# frozen_string_literal: true

class AddShowTotalWithVatToStatements < ActiveRecord::Migration[7.0]
  def change
    add_column :statements, :show_total_with_vat, :boolean, default: false
  end
end
