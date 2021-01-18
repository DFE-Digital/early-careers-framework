# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  belongs_to :course_module
  has_one :next_lesson, class_name: "CourseLesson"
  has_one :previous_lesson, class_name: "CourseLesson"

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }
end
