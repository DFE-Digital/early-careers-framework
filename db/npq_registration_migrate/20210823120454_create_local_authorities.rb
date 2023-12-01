class CreateLocalAuthorities < ActiveRecord::Migration[6.1]
  def change
    create_table :local_authorities do |t|
      t.text :ukprn
      t.text :name

      t.text :address_1
      t.text :address_2
      t.text :address_3
      t.text :town
      t.text :county
      t.text :postcode
      t.text :postcode_without_spaces

      t.boolean :high_pupil_premium, default: false, null: false

      t.timestamps
    end

    add_index :local_authorities, :ukprn
  end
end
