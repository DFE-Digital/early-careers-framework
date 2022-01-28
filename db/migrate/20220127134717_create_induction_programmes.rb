# frozen_string_literal: true

class CreateInductionProgrammes < ActiveRecord::Migration[6.1]
  def change
    create_table :induction_programmes do |t|
      t.references :school_cohort, null: false, foreign_key: true, type: :uuid
      t.references :partnership, null: true, foreign_key: true, type: :uuid
      t.references :core_induction_programme, null: true, foreign_key: true, type: :uuid
      t.string :training_programme, null: false

      t.timestamps
    end
  end
end
