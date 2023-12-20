class CreateSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :schools do |t|
      t.text :urn, null: false
      t.text :la_code
      t.text :la_name
      t.text :establishment_number
      t.text :name

      t.text :establishment_status_code
      t.text :establishment_status_name
      t.date :close_date

      t.text :ukprn

      t.date :last_changed_date

      t.text :address_1 # street
      t.text :address_2 # locality
      t.text :address_3
      t.text :town
      t.text :county
      t.text :postcode

      t.integer :easting
      t.integer :northing

      t.text :region # RSCRegion
      t.text :country

      t.timestamps
    end

    add_index :schools, :urn
  end
end
