# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Participant registration start page",
              type: :feature,
              js: true do
  let!(:user) { create(:user, full_name: "Participant Registration Test User", email: "participant-registration-user@example.com") }
  let(:email_address) { user.email }

  scenario "Participant registration start page is accessible" do
    given_i_am_on_the_participant_registration_start_page
    and_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Participants start registration landing page"
  end

  scenario "Participant can begin registration" do
    given_i_am_on_the_participant_registration_start_page
    and_i_continue_from_participant_registration_start_page
    then_i_am_on_the_sign_in_page
  end

  scenario "Participant can cannot use this service yet" do
    given_i_am_on_the_participant_registration_start_page
    and_i_continue_from_participant_registration_start_page
    then_i_am_on_the_sign_in_page

    when_i_add_email_address_from_sign_in_page email_address
    then_i_am_on_the_sign_in_complete_page

    when_i_continue_from_sign_in_complete_page
    then_i_cannot_use_this_service
  end

  scenario "Participant can complete registrations", :skip do
    given_i_am_on_the_participant_registration_start_page
    and_i_continue_from_participant_registration_start_page
    then_i_am_on_the_sign_in_page

    when_i_add_email_address_from_sign_in_page email_address
    then_i_am_on_the_sign_in_complete_page

    when_i_continue_from_sign_in_complete_page
    then_i_am_on_the_privacy_policy_page
  end

private

  def then_i_cannot_use_this_service
    expect(page.find("h1")).to have_content "You cannot use this service yet"
  end
end
