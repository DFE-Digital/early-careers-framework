# frozen_string_literal: true

class CourseModule < ApplicationRecord
  belongs_to :course_year
  has_many :course_lessons, dependent: :delete_all

  # We use previous_module_id to store the connections between modules
  # The id telling us which module is next lives on the next module, where it is called 'previous_module_id'
  # That's why the foreign key is named contrary to the field name
  has_one :next_module, class_name: "CourseModule", foreign_key: :previous_module_id
  belongs_to :previous_module, class_name: "CourseModule", inverse_of: :next_module, optional: true

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end

  def lessons_with_progress(user)
    ect_profile = user&.early_career_teacher_profile
    return course_lessons unless ect_profile

    user_progresses = CourseLessonProgress.where(early_career_teacher_profile: ect_profile, course_lesson: course_lessons).includes(:course_lesson)
    course_lessons.map do |lesson|
      lesson.progress = user_progresses.find { |progress| progress.course_lesson == lesson }&.progress || "not_started"
      lesson
    end
  end
end
