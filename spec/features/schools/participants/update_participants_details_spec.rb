# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Update participants details", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_have_added_an_ect
    and_i_am_signed_in_as_an_induction_coordinator
    when_i_navigate_to_participants_dashboard
    and_i_have_added_a_mentor
  end

  scenario "Induction tutor can change ECT / mentor email from check details page" do
    set_dqt_validation_result

    when_i_click_to_add_a_new_ect_or_mentor
    then_i_am_taken_to_the_who_do_you_want_to_add_page

    when_i_decide_i_want_to_add_an_ect
    and_i_click_on_continue

    then_i_should_be_on_the_what_we_need_from_you_page
    and_i_click_on_continue

    when_i_add_full_name_to_the_school_add_participant_wizard @participant_data[:full_name]
    and_i_add_teacher_reference_number_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:trn]
    and_i_add_date_of_birth_to_the_school_add_participant_wizard @participant_data[:date_of_birth]
    and_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", @participant_data[:email]
    and_i_add_start_date_to_the_school_add_participant_wizard @participant_data[:start_date]
    and_i_choose_mentor_later_on_the_school_add_participant_wizard
    then_i_am_taken_to_check_details_page

    when_i_click_on_change_email
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_updated_email
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_change_induction_start_date
    when_i_add_a_start_date
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_on_change_mentor
    when_i_choose_assign_mentor_later
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_updated_email
  end

  scenario "Induction tutor can change ECTs mentor from check details page" do
    set_dqt_validation_result

    when_i_click_to_add_a_new_ect_or_mentor
    then_i_am_taken_to_the_who_do_you_want_to_add_page

    when_i_decide_i_want_to_add_an_ect
    and_i_click_on_continue

    then_i_should_be_on_the_what_we_need_from_you_page
    and_i_click_on_continue

    when_i_add_full_name_to_the_school_add_participant_wizard @participant_data[:full_name]
    and_i_add_teacher_reference_number_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:trn]
    and_i_add_date_of_birth_to_the_school_add_participant_wizard @participant_data[:date_of_birth]
    and_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", @participant_data[:email]
    and_i_add_start_date_to_the_school_add_participant_wizard @participant_data[:start_date]
    then_i_am_taken_to_add_mentor_page
    then_the_page_should_be_accessible

    when_i_choose_a_mentor
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_mentor_name

    when_i_click_on_change_mentor
    then_i_am_taken_to_add_mentor_page

    when_i_choose_assign_mentor_later
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_assign_mentor_later_status
  end

  scenario "withdrawn participants" do
    given_an_ect_has_been_withdrawn_by_the_provider
    when_i_visit_manage_training_dashboard
    and_i_click("2021 to 2022")

    when_i_navigate_to_participants_dashboard
    click_on "Not training"
    then_it_should_show_the_withdrawn_participant
    and_the_page_should_be_accessible

    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_am_taken_to_view_details_page
    and_it_should_not_allow_a_sit_to_edit_the_participant_details
    and_the_page_should_be_accessible
  end

  scenario "Induction tutor can't change ECT / mentor name or email for a participant contacted for info" do
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    and_it_should_not_allow_a_sit_to_edit_the_participant_details
  end

  scenario "Induction tutor can change ECT / mentor name form the profile page when their name has changed" do
    given_the_ect_has_been_validated
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    then_the_page_should_be_accessible

    when_i_click_on_change_name
    then_i_am_on_the_reason_to_change_school_participant_name_page
    then_the_page_should_be_accessible
    and_i_confirm_the_participant_on_the_reason_to_change_school_participant_name_page_with_name "Sally Teacher"

    when_i_choose_they_have_changed_their_name_from_the_reason_to_change_school_participant_name_page
    then_i_am_on_the_edit_school_participant_name_page
    then_the_page_should_be_accessible
    and_i_confirm_the_participant_on_the_edit_school_participant_name_page_with_name "Sally Teacher"

    when_i_set_a_blank_name_on_the_edit_school_participant_name_page
    then_i_see_an_error_message "Enter a full name"

    when_i_set_the_name_on_the_edit_school_participant_name_page_with_new_name "Jane Teacher"
    then_i_see_a_confirmation_message_on_the_school_participant_name_updated_page_with_old_name_and_new_name "Sally Teacher", "Jane Teacher"
    then_the_page_should_be_accessible

    when_i_return_to_the_participant_profile_from_the_school_participant_name_updated_page
    then_i_confirm_the_participant_on_the_school_participant_details_page_with_name "Sally Teacher"
  end

  scenario "Induction tutor can change ECT / mentor name form the profile page when their name was incorrect" do
    given_the_ect_has_been_validated
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    when_i_click_on_change_name
    when_i_choose_name_is_incorrect_from_the_reason_to_change_school_participant_name_page
    then_i_am_on_the_edit_school_participant_name_page
    and_i_confirm_the_participant_on_the_edit_school_participant_name_page_with_name "Sally Teacher"

    when_i_set_the_name_on_the_edit_school_participant_name_page_with_new_name "Jane Teacher"
    then_i_see_a_confirmation_message_on_the_school_participant_name_updated_page_with_old_name_and_new_name "Sally Teacher", "Jane Teacher"

    when_i_return_to_the_ect_and_mentors_from_the_school_participant_name_updated_page
    then_i_view_ects_on_the_school_participants_dashboard_page "Jane Teacher"
  end

  scenario "Induction tutor can't remove an ECT / mentor by changing their name in participant profile page" do
    given_the_ect_has_been_validated
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    when_i_click_on_change_name
    when_i_choose_should_not_be_registered_from_the_reason_to_change_school_participant_name_page
    then_i_cant_edit_the_participant_name_on_the_school_participant_should_not_have_been_registered_page "Sally Teacher"
    then_the_page_should_be_accessible
  end

  scenario "Induction tutor can't replace an ECT / mentor by changing their name in participant profile page" do
    given_the_ect_has_been_validated
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    when_i_click_on_change_name
    when_i_choose_replaced_by_a_different_person_from_the_reason_to_change_school_participant_name_page
    then_i_cant_edit_the_participant_name_on_the_school_participant_replaced_by_a_different_person_page "Sally Teacher"
    then_the_page_should_be_accessible
    then_i_can_add_a_participant_from_the_school_participant_replaced_by_a_different_person_page "ECT"
  end

  scenario "Induction tutor can change ECT / mentor email from participant profile page" do
    given_the_ect_has_been_validated
    when_i_view_ects_from_the_school_participants_dashboard_page "Sally Teacher"
    when_i_click_on_change_email
    then_i_am_on_the_edit_school_participant_email_page
    then_the_page_should_be_accessible
    and_i_confirm_the_participant_on_the_edit_school_participant_email_page_with_name "Sally Teacher"

    when_i_set_a_blank_email_on_the_edit_school_participant_email_page
    then_i_see_an_error_message "Enter an email address"

    when_i_set_an_invalid_email_on_the_edit_school_participant_email_page
    then_i_see_an_error_message "Enter an email address"

    when_i_set_the_email_on_the_edit_school_participant_email_page_with_new_email "jane@school.com"
    then_i_see_a_confirmation_message_on_the_school_participant_email_updated_page_with_name "Sally Teacher"
    then_the_page_should_be_accessible

    when_i_return_to_the_participant_profile_from_the_school_participant_email_updated_page
    then_i_confirm_the_participant_on_the_school_participant_details_page_with_name "Sally Teacher"
  end

  context "When the school cohort does not have an appropriate body assigned" do
    scenario "Induction tutor does not see the appropriate body from participant profile page" do
      click_on "Sally Teacher"
      then_i_am_taken_to_participant_profile
      and_i_dont_see_appropriate_body
    end
  end

  context "When the school cohort has an appropriate body assigned" do
    let!(:appropriate_body) { create(:appropriate_body_national_organisation) }
    before do
      @school_cohort.update!(appropriate_body:)
    end

    scenario "Induction tutor can change the appropriate body from participant profile page" do
      given_the_ect_has_been_validated
      click_on "Sally Teacher"
      then_i_am_taken_to_participant_profile
      and_i_see_no_appropriate_body_selected

      when_i_click_on_summary_row_action("Appropriate body", "Add")
      then_i_am_taken_to_the_appropriate_body_type_page

      when_i_choose_an_appropriate_body
      click_on "Return to their details"
      then_i_see_appropriate_body(appropriate_body)
      and_i_can_change_the_appropriate_body
    end
  end
end
