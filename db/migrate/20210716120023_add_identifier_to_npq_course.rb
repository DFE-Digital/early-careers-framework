# frozen_string_literal: true

class AddIdentifierToNPQCourse < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_courses, :identifier, :text, null: true
  end
end
