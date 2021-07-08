# frozen_string_literal: true

class CreateNPQCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_courses do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
