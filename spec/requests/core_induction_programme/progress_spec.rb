# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Progress", type: :request do
  let(:course_lesson) { FactoryBot.create(:course_lesson) }
  let(:progress_url) { "/lessons/#{course_lesson.id}/progress" }
  let(:module_url) { "/modules/#{course_lesson.course_module.id}" }

  describe "when an ECT is logged in" do
    let(:user) { create(:user, :early_career_teacher) }
    let(:progress) do
      CourseLessonProgress.find_by(
        course_lesson: course_lesson,
        early_career_teacher_profile: user.early_career_teacher_profile,
      ).progress
    end
    before do
      sign_in user
    end

    describe "PUT /lessons/:id/progress" do
      it "updates the progress of an ECT" do
        put progress_url, params: { progress: "complete" }
        expect(progress).to eq("complete")
      end

      it "redirects to module when changing progress" do
        put progress_url, params: { progress: "complete" }
        expect(response).to redirect_to(module_url)
      end

      it "redirects to module when not changing progress" do
        put progress_url, params: { progress: "" }
        expect(response).to redirect_to(module_url)
      end
    end
  end
end
