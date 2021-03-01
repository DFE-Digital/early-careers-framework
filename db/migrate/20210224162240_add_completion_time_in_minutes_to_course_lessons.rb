# frozen_string_literal: true

class AddCompletionTimeInMinutesToCourseLessons < ActiveRecord::Migration[6.1]
  def change
    add_column :course_lessons, :completion_time_in_minutes, :integer
  end
end
