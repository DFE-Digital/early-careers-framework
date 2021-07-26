# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Start user journey", type: :feature, rutabaga: false do
  scenario "Root URL should be the home page" do
    when_i_visit_the_home_page
    then_i_should_see_the_service_name
    and_i_should_see_a_start_button
  end

private

  def when_i_visit_the_home_page
    visit "/"
  end

  def then_i_should_see_the_service_name
    expect(page).to have_selector("h1", text: "Manage training for early career teachers")
  end

  def and_i_should_see_a_start_button
    expect(page).to have_selector("a.govuk-button--start", text: "Start now")
  end
end
