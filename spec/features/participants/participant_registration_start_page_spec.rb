# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Participant registration start page",
              type: :feature,
              js: true do
  scenario "Participant registration start page is accessible" do
    given_i_am_on_the_participant_registration_start_page
    and_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Participants start registration landing page"

    when_i_continue_from_participant_registration_start_page

    then_i_am_on_the_sign_in_page
  end
end
