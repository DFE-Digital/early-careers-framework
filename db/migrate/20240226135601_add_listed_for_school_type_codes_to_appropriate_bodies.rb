# frozen_string_literal: true

class AddListedForSchoolTypeCodesToAppropriateBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :appropriate_bodies, :listed_for_school_type_codes, :integer, array: true, default: []
  end
end
