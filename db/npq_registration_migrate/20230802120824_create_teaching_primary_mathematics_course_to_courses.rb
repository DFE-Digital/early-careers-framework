class CreateTeachingPrimaryMathematicsCourseToCourses < ActiveRecord::Migration[6.1]
  def change
    course = Course.find_by(identifier: "npq-leading-primary-mathematics")
    Course.create!(name: "NPQ Leading Primary Mathematics (NPQLPM)", position: 5, display: true, identifier: "npq-leading-primary-mathematics") if course.blank?
  end
end
