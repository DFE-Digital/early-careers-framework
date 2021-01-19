# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseYear, type: :model do
  it "can be created" do
    expect {
      CourseYear.create(
        title: "Test Course year",
        content: "No content",
        is_year_one: false,
        lead_provider: FactoryBot.create(:lead_provider),
      )
    }.to change { CourseYear.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to have_many(:course_modules) }
  end

  describe "validations" do
    subject { FactoryBot.create(:course_year) }
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
  end
end
