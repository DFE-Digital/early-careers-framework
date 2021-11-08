# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    then_i_am_taken_to_fip_induction_dashboard
  end

  scenario "Induction tutor can add new ECT participant" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "ECF roles information"

    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor adds ECT and mentors"

    when_i_click_on_add_ect
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor adds ECT name"

    when_i_click_on_continue
    then_i_receive_a_missing_name_error_message

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor adds ECT email"

    when_i_click_on_continue
    then_i_receive_a_missing_email_error_message

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor checks ECT details"

    when_i_click_confirm_and_add
    then_i_am_taken_to_ect_confirmation_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor receives add ECT Confirmation"
  end

  scenario "Induction tutor can add new mentor participant" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_on_add_mentor
    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_name_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor adds mentor name"

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor adds mentor email"

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_mentor_confirmation_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor receives add mentor Confirmation"
  end

  scenario "Induction tutor can add themselves as a mentor" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_on_add_myself_as_mentor
    then_i_am_taken_to_are_you_sure_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor add yourself as mentor check"

    when_i_click_on_check_what_each_role_needs_to_do
    then_i_am_taken_to_roles_page

    when_i_click_on_back
    then_i_am_taken_to_are_you_sure_page

    when_i_click_on_confirm
    then_i_am_taken_to_yourself_as_mentor_confirmation_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Induction tutor add yourself as mentor confirmation"
  end

  scenario "Induction tutor cannot add existing ECT/mentor" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_on_add_mentor
    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_name_page

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email_that_already_exists
    when_i_click_on_continue
    then_i_receive_an_email_already_taken_error_message
  end
end
