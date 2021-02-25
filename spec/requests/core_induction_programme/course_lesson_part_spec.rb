# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Lesson Part", type: :request do
  let(:course_lesson_part) { FactoryBot.create(:course_lesson_part) }
  let(:course_lesson) { course_lesson_part.course_lesson }
  let(:course_module) { course_lesson.course_module }
  let(:course_year) { course_module.course_year }
  let(:course_lesson_part_url) { "/core-induction-programme/years/#{course_year.id}/modules/#{course_module.id}/lessons/#{course_lesson.id}/parts/#{course_lesson_part.id}" }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "renders the cip lesson part edit page" do
        get "#{course_lesson_part_url}/edit"
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders a preview of changes to lesson part" do
        put course_lesson_part_url, params: { commit: "See preview", content: "Extra content" }
        expect(response).to render_template(:edit)
        expect(response.body).to include("Extra content")
        course_lesson_part.reload
        expect(course_lesson_part.content).not_to include("Extra content")
      end

      it "redirects to the lesson part page when saving content" do
        put course_lesson_part_url, params: { commit: "Save changes", content: "Adding new content" }
        expect(response).to redirect_to(course_lesson_part_url)
        get course_lesson_part_url
        expect(response.body).to include("Adding new content")
      end

      it "redirects to the lesson part page when saving title" do
        put course_lesson_part_url, params: { commit: "Save changes", title: "New title" }
        expect(response).to redirect_to(course_lesson_part_url)
        get course_lesson_part_url
        expect(response.body).to include("New title")
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "renders the cip lesson part split page" do
        get "#{course_lesson_part_url}/split"
        expect(response).to render_template(:show_split)
      end
    end

    describe "POST /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "renders a preview of changes to lesson part" do
        post "#{course_lesson_part_url}/split", params: {
          commit: "See preview",
          split_lesson_part_form: {
            title: "Updated title one",
            content: "Updated content",
            new_title: "Title two",
            new_content: "Content two",
          },
        }
        expect(response).to render_template(:show_split)
        expect(response.body).to include("Updated title one")
        expect(response.body).to include("Updated content")
        expect(response.body).to include("Title two")
        expect(response.body).to include("Content two")

        expect(CourseLessonPart.count).to eq(1)
        course_lesson_part.reload
        expect(course_lesson_part.content).not_to include("Extra content")
      end

      it "splits the lesson part and redirects to show" do
        post "#{course_lesson_part_url}/split", params: {
          commit: "Save changes",
          split_lesson_part_form: {
            title: "Updated title one",
            content: "Updated content",
            new_title: "Title two",
            new_content: "Content two",
          },
        }
        expect(response).to redirect_to(course_lesson_part_url)

        expect(CourseLessonPart.count).to eq(2)
        course_lesson_part.reload
        expect(course_lesson_part.title).to eq "Updated title one"
        expect(course_lesson_part.content).to eq "Updated content"
        expect(course_lesson_part.next_lesson_part.title).to eq "Title two"
        expect(course_lesson_part.next_lesson_part.content).to eq "Content two"

        post "#{course_lesson_part_url}/split", params: {
          commit: "Save changes",
          split_lesson_part_form: {
            title: "Updated title one again",
            content: "Updated content again",
            new_title: "Title one point five",
            new_content: "Content one point five",
          },
        }

        expect(CourseLessonPart.count).to eq(3)
        course_lesson_part.reload
        expect(course_lesson_part.title).to eq "Updated title one again"
        expect(course_lesson_part.content).to eq "Updated content again"
        expect(course_lesson_part.next_lesson_part.title).to eq "Title one point five"
        expect(course_lesson_part.next_lesson_part.content).to eq "Content one point five"
        expect(course_lesson_part.next_lesson_part.next_lesson_part.title).to eq "Title two"
        expect(course_lesson_part.next_lesson_part.next_lesson_part.content).to eq "Content two"
      end
    end
  end

  describe "when a non-admin user is logged in" do
    before do
      user = create(:user)
      sign_in user
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "redirects to the sign in page" do
        expect { get "#{course_lesson_part_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        expect { get "#{course_lesson_part_url}/split" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "POST /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        expect { post "#{course_lesson_part_url}/split" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the lesson part page" do
    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "redirects to the sign in page" do
        get "#{course_lesson_part_url}/edit"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "PUT /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "redirects to the sign in page" do
        put course_lesson_part_url, params: { commit: "Save changes", content: course_lesson_part.content }
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "GET /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        get "#{course_lesson_part_url}/split"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "POST /core-induction-programme/years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        post "#{course_lesson_part_url}/split"
        expect(response).to redirect_to("/users/sign_in")
      end
    end
  end
end
