# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Lesson", type: :request do
  it "renders the cip lesson page" do
    course_lesson = FactoryBot.create(:course_lesson)
    get "/core-induction-programme/#{course_lesson.course_module.course_year.id}/#{course_lesson.course_module.id}/#{course_lesson.id}"
    expect(response).to render_template(:show)
  end
end
