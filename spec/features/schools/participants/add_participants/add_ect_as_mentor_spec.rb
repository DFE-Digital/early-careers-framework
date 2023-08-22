# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Add ECT as mentor", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_cip
    set_participant_data
    and_i_have_added_an_ect_with_email(@participant_data[:email])
    given_there_is_a_school_that_has_chosen_fip_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    set_dqt_validation_result
  end

  scenario "Induction tutor tries to add an ECT that's a mentor in another school" do
    when_i_navigate_to_participants_dashboard
    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    when_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_you_page

    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_full_name_page

    when_i_add_mentor_name
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
    then_i_am_taken_to_mentor_start_training_page

    when_i_choose_summer_term_2023
    when_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_mentor_added_confirmation_page

    click_on "View your ECTs and mentors"
    then_i_see_the_mentor_name
  end
end
