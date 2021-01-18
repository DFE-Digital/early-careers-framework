# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseLesson, type: :model do
  it "can be created" do
    expect {
      CourseLesson.create(
        title: "Test Course lesson",
        content: "No content",
        course_module: FactoryBot.create(:course_module),
      )
    }.to change { CourseLesson.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:course_module) }
    it { is_expected.to have_one(:next_lesson) }
    it { is_expected.to belong_to(:previous_lesson).optional }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_lesson) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
  end
end
