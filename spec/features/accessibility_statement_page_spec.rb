# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Accessibility statement page", type: :feature, js: true, rutabaga: false do
  scenario "Visiting the accessibility statement policy page" do
    given_i_am_on_the_start_page
    when_i_click_accessibility
    then_i_should_be_on_the_accessibility_statement_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Accessibility statement page"
  end

private

  def given_i_am_on_the_start_page
    start_page = Pages::StartPage.new
    start_page.load
    start_page.is_on_page?
  end

  def when_i_click_accessibility
    start_page = Pages::StartPage.new
    start_page.view_accessibility_statement
  end

  def then_i_should_be_on_the_accessibility_statement_page
    accessibility_statement_page = Pages::AccessibilityStatementPage.new
    accessibility_statement_page.is_on_page?
  end
end
