# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Lesson Part", type: :request do
  let(:course_lesson_part) { FactoryBot.create(:course_lesson_part) }
  let(:course_lesson) { course_lesson_part.course_lesson }
  let(:course_module) { course_lesson.course_module }
  let(:course_year) { course_module.course_year }
  let(:course_lesson_part_url) { "/years/#{course_year.id}/modules/#{course_module.id}/lessons/#{course_lesson.id}/parts/#{course_lesson_part.id}" }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "renders the cip lesson part edit page" do
        get "#{course_lesson_part_url}/edit"
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
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

    describe "DELETE /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "deletes a course lesson part and redirects to a course lesson" do
        post "#{course_lesson_part_url}/split", params: {
          commit: "Save changes",
          split_lesson_part_form: {
            title: "Updated title one",
            content: "Updated content",
            new_title: "Title two",
            new_content: "Content two",
          },
        }
        delete course_lesson_part_url, params: { id: course_lesson.course_lesson_parts[1].id }

        course_lesson_url = "/years/#{course_year.id}/modules/#{course_module.id}/lessons/#{course_lesson.id}"

        expect(CourseLessonPart.count).to eq(1)
        expect(response).to redirect_to(course_lesson_url)
      end

      it "raises an authorization error when there is 1 course lesson part" do
        expect { delete course_lesson_part_url, params: { id: course_lesson.course_lesson_parts[0].id } }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "renders the cip lesson part split page" do
        get "#{course_lesson_part_url}/split"
        expect(response).to render_template(:show_split)
      end
    end

    describe "POST /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
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

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/show_delete" do
      it "renders the cip lesson part show_delete page when there is > 1 course lesson part" do
        FactoryBot.create(:course_lesson_part, course_lesson: course_lesson)
        get "#{course_lesson_part_url}/show_delete"
        expect(response).to render_template(:show_delete)
      end

      it "raises an authorization error when there is 1 course lesson part" do
        expect { get "#{course_lesson_part_url}/show_delete" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-admin user is logged in" do
    before do
      user = create(:user)
      sign_in user
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "DELETE /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "raises an authorization error" do
        expect { delete course_lesson_part_url }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "raises an authorization error" do
        expect { get "#{course_lesson_part_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "raises an authorization error" do
        expect { get "#{course_lesson_part_url}/split" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "POST /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "raises an authorization error" do
        expect { post "#{course_lesson_part_url}/split" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/show_delete" do
      it "raises an authorization error" do
        expect { get "#{course_lesson_part_url}/show_delete" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the lesson part page" do
    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "renders the cip lesson part page" do
        get course_lesson_part_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/edit" do
      it "redirects to the sign in page" do
        get "#{course_lesson_part_url}/edit"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "PUT /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "redirects to the sign in page" do
        put course_lesson_part_url, params: { commit: "Save changes", content: course_lesson_part.content }
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        get "#{course_lesson_part_url}/split"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "POST /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/split" do
      it "redirects to the sign in page" do
        post "#{course_lesson_part_url}/split"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "GET /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id/show_delete" do
      it "redirects to the sign in page" do
        get "#{course_lesson_part_url}/show_delete"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "DELETE /years/:years_id/modules/:module_id/lessons/:lesson_id/parts/:part_id" do
      it "redirects to the sign page" do
        delete course_lesson_part_url
        expect(response).to redirect_to("/users/sign_in")
      end
    end
  end
end
