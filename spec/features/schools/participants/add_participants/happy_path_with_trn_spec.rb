# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", with_feature_flags: { change_of_circumstances: "active" }, js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    then_i_am_taken_to_fip_induction_dashboard
    set_dqt_validation_result
  end

  scenario "Induction tutor can add new ECT participant" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "ECF roles information"

    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT and mentors"

    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "A new ECT"
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT name"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Enter a full name")

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_do_you_know_your_teachers_trn_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT do you know teachers TRN"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Select whether you know the teacher reference number (TRN) for the teacher you are adding")

    when_i_select "Yes"
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT trn"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Enter the teacher reference number (TRN) for the teacher you are adding")

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT date of birth"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Enter a date of birth")

    when_i_add_a_date_of_birth
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT email"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Enter an email address")

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_choose_term_page_as_ect
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECT start term"

    when_i_submit_an_empty_form
    then_i_see_an_error_message("Choose a start term")

    when_i_choose_start_term
    when_i_click_on_continue
    then_i_am_taken_to_choose_start_date_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECT induction start date"

    when_i_add_a_start_date
    when_i_click_on_continue
    then_i_am_taken_to_choose_mentor_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECTs mentor"

    when_i_select_a_mentor
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor checks ECT details"

    when_i_click_confirm_and_add
    then_i_am_taken_to_ect_confirmation_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor receives add ECT Confirmation"
  end

  scenario "Induction tutor can add new mentor participant" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "A new mentor"
    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_name_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds mentor name"

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_do_you_know_your_teachers_trn_page

    when_i_select "Yes"
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_choose_term_page_as_mentor

    when_i_choose_start_term
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor checks mentor details"

    when_i_click_confirm_and_add
    then_i_am_taken_to_mentor_confirmation_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor receives add mentor Confirmation"
  end
end
