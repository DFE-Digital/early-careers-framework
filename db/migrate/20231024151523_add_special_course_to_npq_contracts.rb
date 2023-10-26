# frozen_string_literal: true

class AddSpecialCourseToNPQContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :npq_contracts, :special_course, :boolean, null: false, default: false
  end
end
