class CreateSchoolRecord < ActiveRecord::Migration[6.1]
  def change
    create_table :school_records do |t|
      t.datetime :joining_date, null: false
      t.datetime :leaving_date, null: true

      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.references :joining_induction_record, null: false, foreign_key: { to_table: :induction_records }, type: :uuid
      t.references :leaving_induction_record, null: true, foreign_key: { to_table: :induction_records }, type: :uuid
      t.timestamps
    end
  end
end
