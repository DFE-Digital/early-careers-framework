# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseModule, type: :model do
  it "can be created" do
    expect {
      CourseModule.create(
        title: "Test Course module",
        content: "No content",
        course_year: FactoryBot.create(:course_year),
      )
    }.to change { CourseModule.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:course_year) }
    it { is_expected.to have_one(:next_module) }
    it { is_expected.to belong_to(:previous_module).optional }
    it { is_expected.to have_many(:course_lessons) }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_module) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
  end

  describe "course_lessons" do
    it "returns lessons in order after they get updated" do
      course_module = FactoryBot.create(:course_module)
      course_lesson_one = FactoryBot.create(:course_lesson, title: "One", course_module: course_module)
      course_lesson_two = FactoryBot.create(:course_lesson, title: "Two", course_module: course_module)
      course_lesson_three = FactoryBot.create(:course_lesson, title: "Three", course_module: course_module)
      course_lesson_four = FactoryBot.create(:course_lesson, title: "Four", course_module: course_module)

      course_lesson_two.previous_lesson = course_lesson_one
      course_lesson_four.previous_lesson = course_lesson_two
      course_lesson_three.previous_lesson = course_lesson_four
      course_lesson_two.save!
      course_lesson_three.save!
      course_lesson_four.save!

      expected_lessons_with_order = [course_lesson_one, course_lesson_two, course_lesson_four, course_lesson_three]
      expected_lessons_with_order.zip(course_module.course_lessons).each do |expected, actual|
        expect(expected).to eq(actual)
      end
    end
  end
end
