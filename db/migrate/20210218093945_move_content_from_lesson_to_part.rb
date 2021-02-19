# frozen_string_literal: true

class MoveContentFromLessonToPart < ActiveRecord::Migration[6.1]
  def up
    CourseLesson.all.each do |lesson|
      CourseLessonPart.create!(title: "Lesson content", content: lesson.content, course_lesson: lesson)
    end
  end

  def down
    CourseLesson.all.each do |lesson|
      contents = lesson.course_lesson_parts_in_order.map(&:content)
      lesson.update!(content: contents.join("\n\n"))
    end
    CourseLessonPart.delete_all
  end
end
