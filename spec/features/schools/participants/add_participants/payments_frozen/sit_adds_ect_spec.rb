# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"
require_relative "./common_steps"

RSpec.describe "SIT adding an ECT", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "when target cohort payments are frozen" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_ect_dashboard
    when_i_click_to_add_a_new_ect
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "ECT"
    when_i_click_on_continue

    then_i_am_taken_to_the_what_we_need_from_you_page

    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_name
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email(email: @participant_data[:email])
    when_i_click_on_continue

    when_i_click_confirm_and_add
    then_i_see_confirmation_that_the_participant_has_been_added
    and_the_participant_has_been_added_to_the_active_registration_cohort
  end

  scenario "when target cohort payments are not frozen and unfinished 2021 mentor is assigned" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_signed_in_as_an_induction_coordinator

    and_i_have_added_a_mentor_in_cohort(earliest_cohort)
    and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_ect_dashboard
    when_i_click_to_add_a_new_ect
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "ECT"
    when_i_click_on_continue

    then_i_am_taken_to_the_what_we_need_from_you_page

    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_name
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email(email: @participant_data[:email])
    when_i_click_on_continue
    then_i_am_taken_to_choose_mentor_page

    when_i_select("Cohort Mentor")
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_confirm_and_add
    then_i_see_confirmation_that_the_participant_has_been_added
    and_the_participant_has_been_added_to_the_active_registration_cohort
    and_the_mentor_has_been_added_to_the_active_registration_cohort
  end
end
