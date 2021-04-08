# frozen_string_literal: true

class SetFirstAndSecondCourseYearsForCoreInductionProgramme < ActiveRecord::Migration[6.1]
  def up
    CoreInductionProgramme.all.each do |cip|
      course_years = CourseYear.where(core_induction_programme_id: cip[:id])
      course_years.each do |course_year|
        if course_year.is_year_one?
          cip.update!(course_year_one_id: course_year[:id])
        else
          cip.update!(course_year_two_id: course_year[:id])
        end
      end
    end
  end

  def down
    CoreInductionProgramme.all.each do |cip|
      course_year_one = CourseYear.find_by(id: cip[:course_year_one_id])
      course_year_two = CourseYear.find_by(id: cip[:course_year_two_id])
      course_year_one&.update!(is_year_one: true)
      course_year_two&.update!(is_year_one: false)
    end
  end
end
