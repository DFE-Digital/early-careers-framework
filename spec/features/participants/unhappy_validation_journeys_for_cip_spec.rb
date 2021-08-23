# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "Unhappy participant validation journeys for CIP induction", type: :feature, js: true, with_feature_flags: { participant_validation: "active" } do
  include ParticipantValidationSteps

  scenario "ECT provides invalid details" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_ect_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select whether you know your teacher reference number"

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select if your name has changed since ITT"

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"

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
    then_i_should_see_the_cip_checking_details_page_for_invalid_cip_ect
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - CIP ECT"
  end

  scenario "Mentor provides invalid details" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_a_mentor_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select whether you know your teacher reference number"

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_click "Continue"
    then_i_see_an_error_message "Select if your name has changed since ITT"

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_click "Continue"
    then_i_see_an_error_message "Enter your teacher reference number"
    and_i_see_an_error_message "Enter your full name"
    and_i_see_an_error_message "Enter your date of birth"

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
    then_i_should_see_the_cip_checking_details_page_for_invalid_cip_mentor
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Checking details - CIP mentor"
  end
end
