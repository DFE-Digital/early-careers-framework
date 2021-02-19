# frozen_string_literal: true

FactoryBot.define do
  factory :course_lesson do
    title { "Test Course lesson" }
    course_module { FactoryBot.create(:course_module) }

    trait :with_lesson_part do
      after(:create) do |lesson|
        lesson.course_lesson_parts = [CourseLessonPart.create!(course_lesson: lesson, content: "No content", title: "Title")]
      end
    end
  end
end
