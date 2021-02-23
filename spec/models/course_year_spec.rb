# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseYear, type: :model do
  it "can be created" do
    expect {
      CourseYear.create(
        title: "Test Course year",
        content: "No content",
        is_year_one: false,
      )
    }.to change { CourseYear.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:core_induction_programme).optional }
    it { is_expected.to have_many(:course_modules) }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_year) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
    it { is_expected.to validate_length_of(:content).is_at_most(100_000) }
  end

  describe "course_modules" do
    before :each do
      @teacher = FactoryBot.create(:user, :early_career_teacher)

      @course_year = FactoryBot.create(:course_year)
      @course_module_one = FactoryBot.create(:course_module, title: "One", course_year: @course_year)
      @course_lesson_one = FactoryBot.create(:course_lesson, course_module: @course_module_one)
      @course_lesson_two = FactoryBot.create(:course_lesson, course_module: @course_module_one)

      @course_lesson_one_progress = FactoryBot.create(
        :course_lesson_progress, course_lesson: @course_lesson_one, early_career_teacher_profile: @teacher.early_career_teacher_profile
      )
      @course_lesson_two_progress = FactoryBot.create(
        :course_lesson_progress, course_lesson: @course_lesson_two, early_career_teacher_profile: @teacher.early_career_teacher_profile
      )
    end

    it "returns modules in order after they get updated" do
      course_module_two = FactoryBot.create(:course_module, title: "Two", course_year: @course_year)
      course_module_three = FactoryBot.create(:course_module, title: "Three", course_year: @course_year)
      course_module_four = FactoryBot.create(:course_module, title: "Four", course_year: @course_year)

      course_module_two.update!(previous_module: @course_module_one)
      course_module_four.update!(previous_module: course_module_two)
      course_module_three.update!(previous_module: course_module_four)

      expected_lessons_with_order = [@course_module_one, course_module_two, course_module_four, course_module_three]
      @course_year.course_modules_in_order.zip(expected_lessons_with_order).each do |actual, expected|
        expect(actual).to eq(expected)
      end
    end

    it "returns a progress of not_started when all lessons in that module are not_started" do
      module_progress = @course_year.modules_with_progress(@teacher).first
      expect(module_progress.progress).to eql("not_started")
    end

    it "returns a progress of in_progress when one lesson in that module is in_progress" do
      @course_lesson_one_progress.in_progress!

      module_progress = @course_year.modules_with_progress(@teacher).first
      expect(module_progress.progress).to eql("in_progress")
    end

    it "returns a progress of complete when all lessons in that module are complete" do
      @course_lesson_one_progress.complete!
      @course_lesson_two_progress.complete!

      module_progress = @course_year.modules_with_progress(@teacher).first
      expect(module_progress.progress).to eql("complete")
    end
  end
end
