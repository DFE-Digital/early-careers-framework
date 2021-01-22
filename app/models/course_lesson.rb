# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  belongs_to :course_module
  has_one :next_lesson, class_name: "CourseLesson", foreign_key: :next_lesson_id
  belongs_to :previous_lesson, class_name: "CourseLesson", inverse_of: :next_lesson, optional: true

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end
end
