# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "Unhappy participant validation journeys for CIP induction", with_feature_flags: { eligibility_notifications: "active" }, type: :feature, js: true do
  include ParticipantValidationSteps

  scenario "ECT provides invalid details" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"

    when_i_enter_my_details
    and_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click_a_change_link
    then_i_should_see_the_tell_us_your_details_page_filled_in

    when_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click "Confirm and send"
    then_i_should_see_the_cip_checking_details_page_for_invalid_cip_ect
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - CIP ECT"
  end

  scenario "Mentor provides invalid details" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_a_mentor_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"

    when_i_enter_my_details
    and_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click_a_change_link
    then_i_should_see_the_tell_us_your_details_page_filled_in
    and_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click "Confirm and send"
    then_i_should_see_the_cip_checking_details_page_for_invalid_cip_mentor
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - CIP mentor"
  end
end
