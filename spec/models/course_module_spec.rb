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
    it { is_expected.to have_many(:course_lessons) }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_module) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
  end
end
