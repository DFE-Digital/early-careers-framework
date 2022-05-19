# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Error pages", type: :feature, js: true, rutabaga: false do
  scenario "Page Not Found page is accessible" do
    given_i_am_on_the_page_not_found_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Page Not Found page"
  end

  scenario "Internal Server Error page is accessible" do
    given_i_am_on_the_internal_server_error_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Internal Server Error page"
  end

  scenario "Forbidden page is accessible" do
    given_i_am_on_the_forbidden_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Forbidden page"
  end
end
