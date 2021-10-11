# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "ECT participant validation journey for FIP induction", type: :feature, js: true do
  include ParticipantValidationSteps

  scenario "Participant validates their details" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: What is your TRN"

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Have you changed your name"

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Tell us your details"

    when_i_enter_my_details
    and_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_complete_page_for_matched_user
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Complete Partnered FIP"

    when_i_sign_out
    and_i_sign_in_again_as_the_same_user
    then_i_should_see_the_complete_page_for_matched_user
  end

  scenario "Participant has changed their name and updated TRA" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "Yes, I changed my name"
    and_i_click "Continue"
    then_i_should_see_the_confirm_your_name_has_been_updated_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Confirm name updated"

    when_i_select "Yes, my name has been updated"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_my_details
    and_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_complete_page_for_matched_user
  end

  scenario "Participant has changed their name and wishes to continue with previous name" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_enter_my_trn
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "Yes, I changed my name"
    and_i_click "Continue"
    then_i_should_see_the_confirm_your_name_has_been_updated_page

    when_i_select "No, I need to update my name"
    and_i_click "Continue"
    then_i_should_see_the_what_do_you_want_to_do_now_page

    when_i_select "Register for this programme using your previous name (you can update this later)"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_my_details
    and_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_complete_page_for_matched_user
  end

  scenario "Participant corrects their TRN" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_what_is_your_trn_page

    when_i_enter_my_trn_incorrectly
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_my_details
    and_i_click_continue_but_my_trn_is_invalid
    then_i_should_see_the_cannot_find_details_page_with_the_incorrect_trn

    when_i_click_the_change_trn_link
    then_i_should_see_the_what_is_your_trn_page_filled_in_incorrectly

    when_i_enter_my_trn
    and_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_complete_page_for_matched_user
  end
end
