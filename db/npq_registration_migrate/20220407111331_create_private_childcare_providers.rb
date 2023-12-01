class CreatePrivateChildcareProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :private_childcare_providers do |t|
      t.text :provider_urn, null: false
      t.text :provider_name

      t.text :registered_person_urn
      t.text :registered_person_name

      t.text :registration_date

      t.text :provider_status

      t.text :address_1
      t.text :address_2
      t.text :address_3
      t.text :town
      t.text :postcode
      t.text :postcode_without_spaces
      t.text :region
      t.text :local_authority
      t.text :ofsted_region

      t.json :early_years_individual_registers, default: []
      t.boolean :provider_early_years_register_flag
      t.boolean :provider_compulsory_childcare_register_flag

      t.integer :places

      t.timestamps
    end

    add_index :private_childcare_providers, :provider_urn
  end
end
