# frozen_string_literal: true

class AddIneligibilittyReasons < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :declaration_states, bulk: true do |t|
        t.string :state_reason
      end
    end
  end
end
