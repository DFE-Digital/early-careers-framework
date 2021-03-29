# frozen_string_literal: true

class RemoveOldFieldsFromSchools < ActiveRecord::Migration[6.1]
  def change
    remove_reference :schools, :local_authority, null: false, foreign_key: true
    remove_reference :schools, :local_authority_district, null: false, foreign_key: true
    remove_columns :schools, :eligible, :high_pupil_premium, :is_rural, type: :boolean, if_exists: true
  end
end
