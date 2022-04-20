# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Check you have an account page", type: :feature, js: true, rutabaga: false do
  scenario "Visiting the Check you have an account page" do
    given_i_am_on_the_start_page

    when_i_am_ready_to_start
    then_i_am_on_the_sign_in_page

    when_i_click_find_out_how_to_get_access
    then_i_am_on_the_check_account_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Check you have an account page"
  end

private

  def given_i_am_on_the_start_page
    start_page = Pages::StartPage.new
    start_page.load
    start_page.is_current_page?
  end

  def when_i_am_ready_to_start
    start_page = Pages::StartPage.new
    start_page.start_now
  end

  def then_i_am_on_the_sign_in_page
    sign_in_page = Pages::SignInPage.new
    sign_in_page.is_current_page?
  end

  def when_i_click_find_out_how_to_get_access
    sign_in_page = Pages::SignInPage.new
    sign_in_page.find_out_how_to_get_access
  end

  def then_i_am_on_the_check_account_page
    check_account_page = Pages::CheckAccountPage.new
    check_account_page.is_current_page?
  end
end
