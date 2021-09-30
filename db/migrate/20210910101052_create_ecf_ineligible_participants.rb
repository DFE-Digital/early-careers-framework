# frozen_string_literal: true

class CreateECFIneligibleParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_ineligible_participants, id: :uuid do |t|
      t.string :trn, index: { unique: true }
      t.string :reason, null: false

      t.timestamps
    end
  end
end
