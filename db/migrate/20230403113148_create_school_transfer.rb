class CreateSchoolTransfer < ActiveRecord::Migration[6.1]
  def change
    create_table :school_transfers do |t|
      t.datetime :joining_date, null: true
      t.datetime :leaving_date, null: false

      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.references :leaving_school, null: false, foreign_key: { to_table: :schools }, type: :uuid
      t.references :joining_school, null: true, foreign_key: { to_table: :schools }, type: :uuid
      t.references :leaving_provider, null: false, foreign_key: { to_table: :lead_providers }, type: :uuid
      t.references :joining_provider, null: true, foreign_key: { to_table: :lead_providers }, type: :uuid

      t.timestamps
    end
  end
end
