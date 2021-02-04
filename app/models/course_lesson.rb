# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  belongs_to :course_module

  # We use previous_lesson_id to store the connections between lessons
  # The id telling us which lesson is next lives on the next lesson, where it is called 'previous_lesson_id'
  # That's why the foreign key is named contrary to the field name
  has_one :next_lesson, class_name: "CourseLesson", foreign_key: :previous_lesson_id
  belongs_to :previous_lesson, class_name: "CourseLesson", inverse_of: :next_lesson, optional: true

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end
end
