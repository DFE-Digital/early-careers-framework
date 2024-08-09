# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Accessibility statement page", type: :feature, js: true, rutabaga: false do
  scenario "Accessibility statement is accessible" do
    given_i_am_on_the_accessibility_statement_page
    then_the_page_is_accessible
  end

  scenario "Reading the accessibility statement" do
    given_i_am_on_the_start_page
    when_i_view_accessibility_statement_from_the_start_page
    then_i_am_on_the_accessibility_statement_page
  end

  def given_i_am_on_the_accessibility_statement_page
    visit("/accessibility-statement")
  end

  def given_i_am_on_the_start_page
    visit("/")
  end

  def when_i_view_accessibility_statement_from_the_start_page
    click_on "Accessibility"
  end

  def then_i_am_on_the_accessibility_statement_page
    expect(page).to have_text("Accessibility statement for Manage training for early career teachers service")
  end
end
