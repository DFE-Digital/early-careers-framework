# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Swagger docs page", js: true do
  scenario "Swagger docs page should display swagger docs" do
    when_i_visit "/api-docs"
    then_i_should_see_api_text
    and_percy_should_be_sent_a_snapshot_named("Swagger docs page")
  end

private

  def then_i_should_see_api_text
    expect(page).to have_selector("h2", text: "Manage teacher CPD - lead provider API")
  end
end
