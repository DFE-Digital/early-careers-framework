# frozen_string_literal: true

class ColumnsForLpsAndCpdLps < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :lead_providers do |t|
        t.references :cpd_lead_provider, null: true, foreign_key: true, type: :uuid
      end

      change_table :npq_lead_providers do |t|
        t.references :cpd_lead_provider, null: true, foreign_key: true, type: :uuid
      end
    end
  end
end
