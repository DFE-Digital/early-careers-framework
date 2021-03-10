# frozen_string_literal: true

class AddAdministrativeDistrictCodeToSchools < ActiveRecord::Migration[6.1]
  def change
    change_table :schools, bulk: true do |t|
      t.string :administrative_district_code
      t.string :administrative_district_name
    end
  end
end
