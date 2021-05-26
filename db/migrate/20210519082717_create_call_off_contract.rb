# frozen_string_literal: true

class CreateCallOffContract < ActiveRecord::Migration[6.1]
  def change
    create_table :call_off_contracts do |t|
      t.string :version, null: false, default: "0.0.1"
      t.jsonb :raw
      t.decimal :uplift_target
      t.decimal :uplift_amount
      t.integer :recruitment_target
      t.decimal :set_up_fee

      t.timestamps
    end
  end
end
