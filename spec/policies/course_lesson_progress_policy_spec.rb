# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseLessonProgressPolicy, type: :policy do
  let(:course_lesson_progress) { create(:course_lesson_progress) }

  context "being the ect whose progress it is" do
    subject { described_class.new(course_lesson_progress.user, course_lesson_progress) }
    it { is_expected.to permit_action(:update) }
  end

  context "being another ect" do
    let(:user) { create(:user, :early_career_teacher) }
    subject { described_class.new(user, course_lesson_progress) }
    it { is_expected.to forbid_action(:update) }
  end

  context "being a visitor" do
    let(:user) { nil }
    subject { described_class.new(user, course_lesson_progress) }
    it { is_expected.to forbid_action(:update) }
  end
end
