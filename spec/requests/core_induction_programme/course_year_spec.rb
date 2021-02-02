# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Year", type: :request do
  it "renders the cip year page" do
    course_year = FactoryBot.create(:course_year)
    get "/core-induction-programme/years/#{course_year.id}"
    expect(response).to render_template(:show)
  end
end
