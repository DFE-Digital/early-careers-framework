# frozen_string_literal: true

class CreateNPQTeachingPrimaryMathematicsCourseToNPQCourses < ActiveRecord::Migration[7.0]
  def change
    NPQCourse.find_or_create_by!(name: "NPQ for Leading Primary Mathematics (NPQLPM)", identifier: "npq-leading-primary-mathematics")
  end
end
