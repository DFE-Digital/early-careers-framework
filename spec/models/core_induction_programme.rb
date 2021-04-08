# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoreInductionProgramme, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:course_years) }
    it { is_expected.to have_many(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:early_career_teachers).through(:early_career_teacher_profiles) }
    it { is_expected.to belong_to(:course_year_one).optional }
    it { is_expected.to belong_to(:course_year_two).optional }
  end

  describe "course_years" do
    it "returns multiple course years for a single core_induction_programme" do
      core_induction_programme = FactoryBot.create(:core_induction_programme)
      course_year_one = FactoryBot.create(:course_year, core_induction_programme: core_induction_programme)
      course_year_two = FactoryBot.create(:course_year, core_induction_programme: core_induction_programme)

      expect(course_year_one.core_induction_programme).to eql(course_year_two.core_induction_programme)
      expect(core_induction_programme.course_years.count).to eq(2)
    end
  end
end
