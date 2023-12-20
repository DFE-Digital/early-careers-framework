class AddApplicationCourseFk < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :applications, :courses, column: :course_id
  end
end
