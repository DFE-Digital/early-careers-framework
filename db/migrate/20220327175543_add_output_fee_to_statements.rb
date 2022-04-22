# frozen_string_literal: true

class AddOutputFeeToStatements < ActiveRecord::Migration[6.1]
  def change
    add_column :statements, :output_fee, :boolean, default: true
  end
end
