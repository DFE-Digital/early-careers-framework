# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseLessonProgress, type: :model do
  it "is created with the default progress value" do
    course_lesson = CourseLessonProgress.new
    expect(course_lesson[:progress]).to eql("not_started")
  end

  describe "associations" do
    it { is_expected.to belong_to(:course_lesson) }
    it { is_expected.to belong_to(:early_career_teacher_profile) }
  end

  describe "validations" do
    subject { create(:course_lesson_progress) }
    it { is_expected.to validate_uniqueness_of(:course_lesson_id).scoped_to(:early_career_teacher_profile_id).case_insensitive }
  end

  describe "early_career_teacher_profile" do
    context "when early career teachers have records of course lesson progresses" do
      let(:teacher) { create(:early_career_teacher_profile) }
      let(:lesson_one) { create(:course_lesson) }
      let(:lesson_two) { create(:course_lesson) }
      let!(:lesson_one_progress) { create(:course_lesson_progress, early_career_teacher_profile: teacher, course_lesson: lesson_one) }

      it "matches a created course lesson progress to a teachers course lesson progresses" do
        expect(teacher.course_lesson_progresses[0]).to eq(lesson_one_progress)
      end

      it "adds a second lesson record to a teachers progresses" do
        create(:course_lesson_progress, early_career_teacher_profile: teacher, course_lesson: lesson_two)
        expect(teacher.course_lesson_progresses.count).to eql(2)
      end

      it "updates a single lesson record" do
        lesson_one_progress.complete!
        completed_lesson = teacher.course_lesson_progresses.find_by(course_lesson_id: lesson_one)
        expect(completed_lesson[:progress]).to eql("complete")
      end

      it "can not assign an invalid status to a course lesson progress" do
        expect { lesson_one_progress.progress = "part_way_through" }.to raise_error ArgumentError
      end

      it "does not allow the same lesson record progress to be added twice" do
        lesson_one_progress_duplicate = CourseLessonProgress.new(
          early_career_teacher_profile: teacher,
          course_lesson: lesson_one,
        )
        expect(lesson_one_progress_duplicate).not_to be_valid
      end
    end
  end
end
