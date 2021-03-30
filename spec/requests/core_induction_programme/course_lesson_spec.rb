# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Lesson", type: :request do
  let(:course_lesson) { FactoryBot.create(:course_lesson) }
  let(:course_lesson_url) { "/years/#{course_lesson.course_module.course_year.id}/modules/#{course_lesson.course_module.id}/lessons/#{course_lesson.id}" }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /years/:years/modules/:modules/lessons/:lessons" do
      it "renders the cip lesson page if lesson has no parts" do
        get course_lesson_url
        expect(response).to render_template(:show)
      end

      it "redirects to lesson part page of the first part if lesson has no some parts" do
        part_one = CourseLessonPart.create!(course_lesson: course_lesson, content: "Content One", title: "Title One")
        CourseLessonPart.create!(course_lesson: course_lesson, content: "Content Two", title: "Title Two")
        get course_lesson_url
        expect(response).to redirect_to("#{course_lesson_url}/parts/#{part_one.id}")
      end

      it "does not track progress" do
        get course_lesson_url
        expect(CourseLessonProgress.count).to eq(0)
      end

      it "renders the cip edit lesson page" do
        get "#{course_lesson_url}/edit"
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /years/:years/modules/:modules/lessons/:lessons" do
      it "redirects to the lesson page when saving title" do
        put course_lesson_url, params: { course_lesson: { commit: "Save changes", title: "New title" } }
        expect(response).to redirect_to(course_lesson_url)
        get course_lesson_url
        expect(response.body).to include("New title")
      end

      it "redirects to the lesson page when saving minutes" do
        put course_lesson_url, params: { course_lesson: { commit: "Save changes", completion_time_in_minutes: 80 } }
        expect(response).to redirect_to(course_lesson_url)
        get course_lesson_url
        expect(response.body).to include("Duration: 1 hour 20 minutes")
      end

      it "renders the error page with an error when an invalid number is inputted" do
        put course_lesson_url, params: { course_lesson: { commit: "Save changes", completion_time_in_minutes: -10 } }
        expect(response).to render_template(:edit)
        expect(response.body).to include("Enter a number greater than 0")
      end

      it "allows a course lesson to be reassigned to a different course module" do
        second_course_module = FactoryBot.create(:course_module)
        put course_lesson_url, params: { course_lesson: { commit: "Save changes", course_module_id: second_course_module[:id] } }
        course_lesson.reload
        expect(course_lesson[:course_module_id]).to eq(second_course_module[:id])
      end
    end
  end

  describe "when a non-admin user is logged in" do
    before do
      user = create(:user)
      sign_in user
    end

    describe "GET /years/:years/modules/:modules/:lessons" do
      it "renders the cip lesson page" do
        get course_lesson_url
        expect(response).to render_template(:show)
      end

      it "does not track progress" do
        get course_lesson_url
        expect(CourseLessonProgress.count).to eq(0)
      end
    end

    describe "GET /years/:years/modules/:modules/lessons/:lessons/edit" do
      it "redirects to the sign in page" do
        expect { get "#{course_lesson_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the lesson page" do
    describe "GET /years/:years/modules/:modules/lessons/:lessons" do
      it "renders the cip lesson page" do
        get course_lesson_url
        expect(response).to render_template(:show)
      end

      it "does not track progress" do
        get course_lesson_url
        expect(CourseLessonProgress.count).to eq(0)
      end
    end

    describe "GET /years/:years/modules/:modules/lessons/:lessons/edit" do
      it "redirects to the sign in page" do
        get "#{course_lesson_url}/edit"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "PUT /years/:years/modules/:modules/lessons/:lessons" do
      it "redirects to the sign in page" do
        put course_lesson_url, params: { commit: "Save changes" }
        expect(response).to redirect_to("/users/sign_in")
      end
    end
  end

  describe "when a ECT is accessing the lesson page" do
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

    describe "GET /years/:years/modules/:modules/:lessons" do
      it "sets progress to 'in progress' when lesson is not started by the user" do
        get course_lesson_url
        expect(progress).to eq("in_progress")
      end

      it "leaves progress unchanged when lesson is completed" do
        CourseLessonProgress.create!(
          course_lesson: course_lesson,
          early_career_teacher_profile: user.early_career_teacher_profile,
          progress: "complete",
        )
        get course_lesson_url
        expect(progress).to eq("complete")
      end
    end
  end
end
