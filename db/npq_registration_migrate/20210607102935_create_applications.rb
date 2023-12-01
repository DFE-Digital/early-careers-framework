class CreateApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :applications do |t|
      t.references :user, index: true, null: false
      t.references :course, null: false
      t.references :lead_provider, null: false
      t.text :school_urn, null: false
      t.boolean :headerteacher_over_two_years

      t.timestamps
    end
  end
end
