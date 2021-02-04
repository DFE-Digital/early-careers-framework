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
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
  end

  describe "course_modules" do
    it "returns modules in order after they get updated" do
      course_year = FactoryBot.create(:course_year)
      course_module_one = FactoryBot.create(:course_module, title: "One", course_year: course_year)
      course_module_two = FactoryBot.create(:course_module, title: "Two", course_year: course_year)
      course_module_three = FactoryBot.create(:course_module, title: "Three", course_year: course_year)
      course_module_four = FactoryBot.create(:course_module, title: "Four", course_year: course_year)

      course_module_two.previous_module = course_module_one
      course_module_four.previous_module = course_module_two
      course_module_three.previous_module = course_module_four
      course_module_two.save!
      course_module_three.save!
      course_module_four.save!

      expected_modules_with_order = [course_module_one, course_module_two, course_module_four, course_module_three]
      expected_modules_with_order.zip(course_year.course_modules).each do |expected, actual|
        expect(expected).to eq(actual)
      end
    end
  end
end
