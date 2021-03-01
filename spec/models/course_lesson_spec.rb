# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseLesson, type: :model do
  it "can be created" do
    expect {
      CourseLesson.create(
        title: "Test Course lesson",
        course_module: FactoryBot.create(:course_module),
        completion_time_in_minutes: 10,
      )
    }.to change { CourseLesson.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:course_module) }
    it { is_expected.to have_one(:next_lesson) }
    it { is_expected.to belong_to(:previous_lesson).optional }
    it { is_expected.to have_many(:course_lesson_parts) }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_lesson) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_numericality_of(:completion_time_in_minutes).is_greater_than(0).with_message("Enter a number greater than 0") }
  end

  describe ".duration_in_minutes_in_words" do
    before :each do
      @course_lesson = FactoryBot.create(:course_lesson)
    end

    it "returns an integer < 60 converted to words showing just minutes" do
      @course_lesson.completion_time_in_minutes = 55
      expect(@course_lesson.duration_in_minutes_in_words).to eql("55 minutes")
    end

    it "returns an integer > 59 & < 120 converted to words showing the singular of hour and minute" do
      @course_lesson.completion_time_in_minutes = 61
      expect(@course_lesson.duration_in_minutes_in_words).to eql("1 hour 1 minute")
    end

    it "returns hours and minutes pluralized" do
      @course_lesson.completion_time_in_minutes = 122
      expect(@course_lesson.duration_in_minutes_in_words).to eql("2 hours 2 minutes")
    end
  end
end
