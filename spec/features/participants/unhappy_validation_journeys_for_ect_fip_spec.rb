# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "Unhappy ECT participant validation journeys for FIP induction", with_feature_flags: { eligibility_notifications: "active" }, type: :feature, js: true do
  include ParticipantValidationSteps

  scenario "Participant provides invalid details" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: What is your TRN - error"

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Tell us your details - error"

    when_i_enter_my_details
    and_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click_a_change_link
    then_i_should_see_the_tell_us_your_details_page_filled_in
    when_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click "Confirm and send"
    then_i_should_see_the_fip_checking_details_page_for_invalid_user
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - Partnered FIP"
  end

  scenario "Participant already has a different TRN set" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant_with_a_trn_already_set
    then_i_should_see_the_what_is_your_trn_page

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_my_details
    when_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_fip_checking_details_page_for_existing_trn_user
  end

  scenario "Participant does not know their TRN" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    and_i_click "I do not have a TRN number"
    then_i_should_see_the_get_a_trn_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Get a TRN"
  end
end
