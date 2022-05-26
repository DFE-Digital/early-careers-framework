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
  end

  scenario "Induction tutor can add new ECT participant" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page

    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "A new ECT"
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_do_you_know_your_teachers_trn_page

    when_i_select "No"
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_choose_start_date_page

    when_i_add_a_start_date
    when_i_click_on_continue
    then_i_am_taken_to_choose_mentor_page

    when_i_select_a_mentor
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_ect_confirmation_page
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

    when_i_add_ect_or_mentor_name
    when_i_click_on_continue
    then_i_am_taken_to_do_you_know_your_teachers_trn_page

    when_i_select "No"
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_mentor_confirmation_page
  end
end
