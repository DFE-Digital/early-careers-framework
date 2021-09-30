# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Participant start registration journey", type: :feature do
  scenario "Visit the registration landing page", js: true do
    when_i_visit_the_start_registration_page
    then_i_should_see_the_registration_heading
    and_i_should_see_a_continue_button
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participants start registration landing page"
  end

private

  def when_i_visit_the_start_registration_page
    visit participants_start_registrations_path
  end

  def then_i_should_see_the_registration_heading
    expect(page).to have_selector("h1", text: "Register for early career training and support")
  end

  def and_i_should_see_a_continue_button
    expect(page).to have_link("Continue", href: new_user_session_path)
  end
end
