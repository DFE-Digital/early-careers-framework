# frozen_string_literal: true

class CreateStatements < ActiveRecord::Migration[6.1]
  def change
    create_table :statements do |t|
      t.text :type, null: false
      t.text :name, null: false
      t.references :cpd_lead_provider
      t.date :deadline_date
      t.date :payment_date

      t.timestamps
    end
  end
end
