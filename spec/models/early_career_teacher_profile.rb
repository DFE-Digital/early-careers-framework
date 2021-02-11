# frozen_string_literal: true

require "rails_helper"

RSpec.describe EarlyCareerTeacherProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:core_induction_programme).optional }
    it { is_expected.to belong_to(:cohort).optional }
    it { is_expected.to have_many(:course_lesson_progresses) }
    it { is_expected.to have_many(:course_lessons).through(:course_lesson_progresses) }
  end
end
