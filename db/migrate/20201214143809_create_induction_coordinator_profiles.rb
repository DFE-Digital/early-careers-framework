# frozen_string_literal: true

class CreateInductionCoordinatorProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :induction_coordinator_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
