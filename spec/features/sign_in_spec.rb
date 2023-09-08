# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Sign in", type: :feature, js: true, rutabaga: false do
  scenario "Signing in from the Start page" do
    given_i_am_on_the_start_page
    when_i_start_now_from_the_start_page
    then_i_am_on_the_sign_in_page

    when_i_fill_in_the_email_adress
    and_click_on_sign_in
    then_i_see_the_confirmation_message
  end

private

  def when_i_fill_in_the_email_adress
    fill_in "Email address", with: "user@myschool.org"
  end

  def and_click_on_sign_in
    click_on "Sign in"
  end

  def then_i_see_the_confirmation_message
    expect(page).to have_text("We've sent an email to user@myschool.org")
  end
end
