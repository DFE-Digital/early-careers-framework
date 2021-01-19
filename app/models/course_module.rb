# frozen_string_literal: true

class CourseModule < ApplicationRecord
  belongs_to :course_year
  has_one :next_module, class_name: "CourseModule", foreign_key: :next_module_id
  belongs_to :previous_module, class_name: "CourseModule", inverse_of: :next_module, optional: true
  has_many :course_lessons

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }
end
