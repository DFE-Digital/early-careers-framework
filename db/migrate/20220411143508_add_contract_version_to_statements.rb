# frozen_string_literal: true

class AddContractVersionToStatements < ActiveRecord::Migration[6.1]
  def change
    add_column :statements, :contract_version, :string, default: "0.0.1"
  end
end
