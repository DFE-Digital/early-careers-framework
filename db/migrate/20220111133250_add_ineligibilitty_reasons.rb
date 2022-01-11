# frozen_string_literal: true

class AddIneligibilittyReasons < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :declaration_states, bulk: true do |t|
        t.enum :state_reason, as: "state_reason_type"
      end
    end
  end
end
