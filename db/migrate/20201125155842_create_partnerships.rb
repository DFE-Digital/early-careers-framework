# frozen_string_literal: true

class CreatePartnerships < ActiveRecord::Migration[6.0]
  def change
    create_table :partnerships, id: :uuid do |t|
      t.timestamps
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :lead_provider, null: false, foreign_key: true, type: :uuid
      t.column :confirmed_at, :datetime
    end
  end
end
