# frozen_string_literal: true

class RemoveContentFromLessons < ActiveRecord::Migration[6.1]
  def change
    remove_column :course_lessons, :content, type: :string
  end
end
