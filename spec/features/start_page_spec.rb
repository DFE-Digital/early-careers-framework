# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Start user journey", type: :feature, js: true, rutabaga: false do
  scenario "Start page is accessible" do
    given_i_am_on_the_start_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Start page"
  end

  scenario "Root URL should be the Start page" do
    given_i_am_at_the_root_of_the_service
    and_i_am_on_the_start_page
    when_i_click_start_now
    then_i_am_on_the_sign_in_page
  end

private

  def when_i_click_start_now
    start_page = Pages::StartPage.new
    start_page.start_now
  end
end
