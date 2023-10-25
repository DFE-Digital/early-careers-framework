# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adding mentor", js: true, travel_to: Date.new(2023, 5, 1) do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_cip
    given_there_is_a_school_that_has_chosen_fip_and_partnered
    set_participant_data
    set_dqt_validation_result
  end

  scenario "Induction tutor adds themself as mentor using their own email address" do
    when_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_participants_dashboard
    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_full_name_page

    when_i_add_mentor_name
    and_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    and_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    and_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_sits_email
    and_i_click_on_continue
    then_i_am_taken_to_are_you_sure_page

    when_i_click_on_confirm
    then_i_am_taken_to_sit_mentor_start_training_page

    when_i_choose_summer_term_2023
    and_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_sit_mentor_added_confirmation_page

    when_i_click_on "View your ECTs and mentors"
    then_i_see_the_sit_name
  end

  scenario "Induction tutor adds themself as mentor using their own email address when email and TRN belongs to an existing mentor" do
    given_there_is_a_sit_and_mentor_in_difference_schools

    when_i_sign_in_as_sit
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_participants_dashboard
    and_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_full_name_page

    when_i_add_mentor_name
    and_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    and_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    and_i_click_on_continue
    then_i_am_taken_to_only_mentor_ects_at_your_school_page

    when_i_choose_yes
    and_i_click_on_confirm
    then_i_am_taken_to_when_is_participant_moving_to_school_page

    when_i_add_a_start_date
    and_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    and_i_click_on_continue
    then_i_am_taken_to_continue_current_training_page

    when_i_choose_yes
    and_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_yourself_as_mentor_confirmation_page

    when_i_click_on "View your ECTs and mentors"
    then_i_see_the_transferred_mentor_name
  end

  scenario "Induction tutor adds a new mentor" do
    given_there_is_a_sit

    when_i_sign_in_as_sit
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_participants_dashboard
    and_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_full_name_page

    when_i_add_mentor_name
    and_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    and_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    and_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    and_i_click_on_continue
    then_i_am_taken_to_mentor_start_training_page

    when_i_choose_summer_term_2023
    and_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_mentor_added_confirmation_page

    when_i_click_on "View your ECTs and mentors"
    then_i_see_the_mentor_name
  end
end
