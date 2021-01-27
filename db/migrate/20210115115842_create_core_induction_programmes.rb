# frozen_string_literal: true

class CreateCoreInductionProgrammes < ActiveRecord::Migration[6.1]
  def change
    create_table :core_induction_programmes, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
