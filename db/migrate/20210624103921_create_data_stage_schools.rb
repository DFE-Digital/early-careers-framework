# frozen_string_literal: true

class CreateDataStageSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :data_stage_schools, id: :uuid do |t|
      t.string :urn, null: false
      t.string :name, null: false
      t.string :ukprn

      t.integer :school_phase_type
      t.string :school_phase_name
      t.integer :school_type_code
      t.string :school_type_name
      t.integer :school_status_code
      t.string :school_status_name
      t.string :administrative_district_code
      t.string :administrative_district_name

      t.string :address_line1, null: false
      t.string :address_line2
      t.string :address_line3
      t.string :postcode, null: false

      t.string :primary_contact_email
      t.string :secondary_contact_email
      t.string :school_website

      t.timestamps
    end

    add_index :data_stage_schools, :urn, unique: true
  end
end
