# frozen_string_literal: true

class AddFieldsToECFSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_schools, :school_type_name, :string
    add_column :ecf_schools, :school_phase_type, :integer
    add_column :ecf_schools, :school_phase_name, :string
    add_column :ecf_schools, :school_status_code, :integer
    add_column :ecf_schools, :school_status_name, :string
    add_column :ecf_schools, :postcode, :string
    add_column :ecf_schools, :administrative_district_code, :string
    add_column :ecf_schools, :administrative_district_name, :string
  end
end
