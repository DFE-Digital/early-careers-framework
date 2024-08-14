# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Participant registration start page",
              type: :feature,
              js: true do
  let!(:user) { create(:user, full_name: "Participant Registration Test User", email: "participant-registration-user@example.com") }
  let(:email_address) { user.email }

  scenario "Participant registration start page is accessible" do
    given_i_am_on_the_participant_registration_start_page

    then_the_page_is_accessible
  end

  scenario "Participant can begin registration" do
    given_i_am_on_the_participant_registration_start_page

    and_i_continue

    then_i_am_on_the_sign_in_page
  end

  describe "when registration is not currently open" do
    scenario "Participant can cannot use this service yet" do
      given_i_am_on_the_participant_registration_start_page
      and_i_continue

      when_i_sign_in_as_the_user_with_the_email email_address

      then_i_cannot_use_this_service
    end
  end

private

  def then_i_cannot_use_this_service
    expect(page.find("h1")).to have_content "You cannot use this service yet"
  end

  def given_i_am_on_the_participant_registration_start_page
    visit "/participants/start-registration"
  end

  def and_i_continue
    click_on "Continue"
  end

  def then_i_am_on_the_sign_in_page
    expect(page).to have_text "Sign in"
  end
end
