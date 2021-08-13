# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "SIT/mentor participant validation journeys for FIP induction", type: :feature, js: true, with_feature_flags: { participant_validation: "active" } do
  include ParticipantValidationSteps

  scenario "SIT/Mentor Participant validates their details" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_a_sit_mentor_participant
    then_i_should_see_the_do_you_want_to_add_your_mentor_information_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Do you want to add your mentor information"
    when_i_select "Yes, I want to add information now"
    and_i_click "Continue"
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_the_participants_details
    and_i_click "Continue"
    then_i_should_see_the_confirm_details_page

    when_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_checking_details_page_for_a_sit_mentor
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: SIT/Mentor Complete Partnered FIP"

    when_i_sign_out
    and_i_sign_in_again_as_the_same_user
    then_i_should_see_the_manage_your_training_page
    and_i_should_not_see_a_banner_telling_me_i_need_to_add_my_mentor_information
  end

  scenario "SIT/Mentor Participant chooses to do it later and then changes their mind" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_a_sit_mentor_participant
    then_i_should_see_the_do_you_want_to_add_your_mentor_information_page

    when_i_select "No, I’ll do it later"
    and_i_click "Continue"
    then_i_should_see_the_manage_your_training_page
    and_i_should_see_a_banner_telling_me_i_need_to_add_my_mentor_information
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: SIT/Mentor dashboard banner"

    when_i_click "Update now"
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_the_participants_details
    and_i_click "Continue"
    then_i_should_see_the_confirm_details_page

    when_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_checking_details_page_for_a_sit_mentor
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: SIT/Mentor Complete Partnered FIP"

    when_i_click "Manage induction for your school"
    then_i_should_see_the_manage_your_training_page
    and_i_should_not_see_a_banner_telling_me_i_need_to_add_my_mentor_information
  end

  scenario "SIT/Mentor outside of beta does not see journey", with_feature_flags: { participant_validation: "inactive" } do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_a_sit_mentor_participant
    then_i_should_see_the_manage_your_training_page
    and_i_should_not_see_a_banner_telling_me_i_need_to_add_my_mentor_information
  end
end
