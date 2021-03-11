# frozen_string_literal: true

class AddCourseTerms < ActiveRecord::Migration[6.1]
  def change
    add_column :course_modules, :term, :string, default: "spring"
  end
end
