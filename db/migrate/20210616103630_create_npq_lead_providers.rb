# frozen_string_literal: true

class CreateNpqLeadProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_lead_providers do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
