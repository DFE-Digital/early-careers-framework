# frozen_string_literal: true

class AddVersionToCipContent < ActiveRecord::Migration[6.1]
  def change
    add_column :course_years, :version, :integer, null: false, default: 1
    add_column :course_modules, :version, :integer, null: false, default: 1
    add_column :course_lessons, :version, :integer, null: false, default: 1
  end
end
