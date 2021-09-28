# frozen_string_literal: true

require "rails_helper"
require_relative "../dashboard/manage_training_steps"

RSpec.describe "Add participants", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    then_i_should_see_the_fip_induction_dashboard
    when_i_click_add_your_early_career_teacher_and_mentor_details
  end

  scenario "Induction tutor can add new ECT participant" do
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT and mentors"

    when_i_select_add_ect
    and_select_continue
    then_i_am_taken_to_add_ect_name_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT name"
    and_select_continue
    then_i_receive_a_missing_name_error_message

    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT email"
    and_select_continue
    then_i_receive_a_missing_email_error_message

    when_i_add_ect_or_mentor_email
    and_select_continue
    then_i_am_taken_to_check_details_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Check details"

    when_i_select_confirm_and_add
    then_i_should_be_taken_to_ect_confirmation_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Confirmation"
  end

  scenario "Induction tutor can add new mentor participant" do
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
    when_i_select_add_mentor
    and_select_continue

    then_i_am_taken_to_add_mentor_name_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add mentor name"

    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    and_select_continue
    then_i_am_taken_to_check_details_page

    when_i_select_confirm_and_add
    then_i_should_be_taken_to_mentor_confirmation_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Mentor confirmation"
  end

  scenario "Induction tutor can add themselves as a mentor" do
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
    when_i_select_add_myself_as_mentor
    and_select_continue
    then_i_am_taken_to_are_you_sure_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Are you sure"

    when_i_click_on_check_what_each_role_needs_to_do
    then_i_am_taken_to_roles_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Roles"
    and_select_back
    then_i_am_taken_to_are_you_sure_page
    and_select_confirm
    then_i_am_taken_to_yourself_as_mentor_confirmation_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Yourself as mentor confirmation"
  end

  scenario "Induction tutor cannot add existing ECT/mentor" do
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
    when_i_select_add_mentor
    and_select_continue
    then_i_am_taken_to_add_mentor_name_page

    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email_that_already_exists
    and_select_continue
    then_i_will_see_email_already_taken_error_message
  end
end
