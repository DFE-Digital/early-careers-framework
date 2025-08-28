# frozen_string_literal: true

class AddMentorContractVersionToStatements < ActiveRecord::Migration[7.1]
  def change
    add_column :statements, :mentor_contract_version, :string, default: "0.0.1"
  end
end
