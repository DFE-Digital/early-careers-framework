# frozen_string_literal: true

class CourseModule < ApplicationRecord
  belongs_to :course_year
  has_one :next_module, class_name: "CourseModule"
  has_one :previous_module, class_name: "CourseModule"
  has_many :course_lessons

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }
end
