# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Start user journey", type: :feature, js: true, rutabaga: false do
  scenario "Start page is accessible" do
    given_i_am_on_the_start_page
    then_the_page_is_accessible
  end

  scenario "Root URL should be the Start page" do
    given_i_am_at_the_root_of_the_service
    then_i_am_on_the_start_page
  end

  scenario "Signing in from the Start page" do
    given_i_am_on_the_start_page
    when_i_start_now_from_the_start_page
    then_i_am_on_the_sign_in_page
  end

private

  def given_i_am_at_the_root_of_the_service
    visit "/"
  end
end
