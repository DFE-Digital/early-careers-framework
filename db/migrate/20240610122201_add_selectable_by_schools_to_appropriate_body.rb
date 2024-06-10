# frozen_string_literal: true

class AddSelectableBySchoolsToAppropriateBody < ActiveRecord::Migration[7.1]
  def change
    add_column :appropriate_bodies, :selectable_by_schools, :boolean, null: false, default: true
  end
end
