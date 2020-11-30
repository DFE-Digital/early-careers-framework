class CreateSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :schools, id: :uuid do |t|
      t.timestamps
      t.column :urn, :string, null: false
      t.column :name, :string, null: false
      t.column :school_type, :string
      t.column :capacity, :integer
      t.column :high_pupil_premium, :boolean, null: false, default: false
      t.column :is_rural, :boolean, null: false, default: false

      t.column :address_line1, :string, null: false
      t.column :address_line2, :string
      t.column :address_line3, :string
      t.column :address_line4, :string
      t.column :country, :string, null: false
      t.column :postcode, :string, null: false
    end
    add_index :schools, :urn, unique: true
    add_index :schools, :name
    add_index :schools, :high_pupil_premium, where: :high_pupil_premium
    add_index :schools, :is_rural, where: :is_rural
  end
end
