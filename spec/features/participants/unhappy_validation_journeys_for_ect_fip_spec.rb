# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "Unhappy ECT participant validation journeys for FIP induction", type: :feature, js: true, with_feature_flags: { participant_validation: "active" } do
  include ParticipantValidationSteps

  scenario "Participant provides invalid details" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select whether you know your teacher reference number"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Do you know your TRN - error"

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select if your name has changed since ITT"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Have you changed your name - error"

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Tell us your details - error"

    when_i_enter_the_participants_details
    and_i_click "Continue"
    then_i_should_see_the_confirm_details_page

    when_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page

    when_i_click "Try again"
    then_i_should_see_the_tell_us_your_details_page_filled_in
    when_i_click "Continue"
    then_i_should_see_the_confirm_details_page

    when_i_click_continue_but_my_details_are_invalid
    then_i_should_see_the_cannot_find_details_page_with_continue_option

    when_i_click "Continue registration"
    then_i_should_see_the_checking_details_page_for_invalid_user
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - Partnered FIP"
  end

  scenario "Participant does not know their TRN" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "No, I do not know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_find_your_trn_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Find your TRN"
  end

  scenario "Participant does not have a TRN" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "I do not have a TRN"
    and_i_click "Continue"
    then_i_should_see_the_get_a_trn_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Get a TRN"
  end

  scenario "Participant has changed their name and wishes to update TRA" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "Yes, I changed my name"
    and_i_click "Continue"
    then_i_should_see_the_confirm_your_name_has_been_updated_page

    when_i_select "No, I need to update my name"
    and_i_click "Continue"
    then_i_should_see_the_what_do_you_want_to_do_now_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: What do you want to do now"

    when_i_select "Update your name with the Teaching Regulation Agency"
    and_i_click "Continue"
    then_i_should_see_the_change_your_details_with_the_tra_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Change your details with the TRA"
  end
end
