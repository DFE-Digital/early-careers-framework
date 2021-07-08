# frozen_string_literal: true

class CreateCpdLeadProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :cpd_lead_providers, id: :uuid do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
