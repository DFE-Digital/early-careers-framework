# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Error pages", type: :feature, js: true, rutabaga: false do
  scenario "Page Not Found page is accessible" do
    given_i_am_on_the_page_not_found_page
    then_the_page_is_accessible
  end

  scenario "Internal Server Error page is accessible" do
    given_i_am_on_the_internal_server_error_page
    then_the_page_is_accessible
  end

  scenario "Forbidden page is accessible" do
    given_i_am_on_the_forbidden_page
    then_the_page_is_accessible
  end
end
