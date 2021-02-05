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

      course_module_two.update!(previous_module: course_module_one)
      course_module_four.update!(previous_module: course_module_two)
      course_module_three.update!(previous_module: course_module_four)

      expected_lessons_with_order = [course_module_one, course_module_two, course_module_four, course_module_three]
      course_year.course_modules.zip(expected_lessons_with_order).each do |actual, expected|
        expect(actual).to eq(expected)
      end
    end
  end
end
