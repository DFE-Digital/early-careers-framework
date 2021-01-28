# frozen_string_literal: true

class AddGiasFieldsToSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :local_authority_districts, id: :uuid do |t|
      t.timestamps
      t.string :code
      t.string :name

      t.index :code, unique: true
    end

    create_table :local_authorities, id: :uuid do |t|
      t.timestamps
      t.string :code
      t.string :name

      t.index :code, unique: true
    end

    add_reference :schools, :local_authority_district, foreign_key: true, type: :uuid
    add_reference :schools, :local_authority, foreign_key: true, type: :uuid

    change_table :schools, bulk: true do |t|
      t.rename :school_type, :school_type_code
      t.string :school_type_name
      t.string :ukprn
      t.string :previous_school_urn
      t.string :school_phase_type
      t.string :school_phase_name
      t.string :school_website
      t.string :school_status_code
      t.string :school_status_name
      t.string :primary_contact_email
      t.string :secondary_contact_email
    end

    change_table :networks, bulk: true do |t|
      t.string :group_type
      t.string :group_type_code
      t.string :group_id
      t.string :group_uid

      t.string :secondary_contact_email
    end
  end
end
