# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Module", type: :request do
  it "renders the cip module page" do
    course_module = FactoryBot.create(:course_module)
    get "/core-induction-programme/#{course_module.course_year.id}/#{course_module.id}"
    expect(response).to render_template(:show)
  end
end
