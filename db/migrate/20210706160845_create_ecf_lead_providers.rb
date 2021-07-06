# frozen_string_literal: true

class CreateEcfLeadProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_lead_providers, id: :uuid do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
