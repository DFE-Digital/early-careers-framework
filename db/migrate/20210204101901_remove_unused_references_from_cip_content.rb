# frozen_string_literal: true

class RemoveUnusedReferencesFromCipContent < ActiveRecord::Migration[6.1]
  def change
    remove_reference :course_lessons, :next_lesson
    remove_reference :course_modules, :next_module
  end
end
