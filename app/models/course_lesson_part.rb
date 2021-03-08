# frozen_string_literal: true

class CourseLessonPart < ApplicationRecord
  belongs_to :course_lesson

  has_one :next_lesson_part, class_name: "CourseLessonPart", foreign_key: :previous_lesson_part_id, dependent: :nullify
  belongs_to :previous_lesson_part, class_name: "CourseLessonPart", inverse_of: :next_lesson_part, optional: true

  validates :title, presence: { message: "Enter a title" }, length: { maximum: 255 }
  validates :content, presence: { message: "Enter content" }, length: { maximum: 100_000 }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end
end
