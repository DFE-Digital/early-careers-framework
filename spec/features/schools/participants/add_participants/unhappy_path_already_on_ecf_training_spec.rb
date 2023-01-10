# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", with_feature_flags: { change_of_circumstances: "active" }, js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_have_added_a_mentor
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on("2021 to 2022")
    then_i_am_taken_to_fip_induction_dashboard
    set_participant_data
    set_dqt_validation_result
  end

  context "When participant already on ECF from the same school" do
    before do
      given_a_participant_from_the_same_school_is_already_on_ecf
    end

    scenario "Induction tutor tries to add ppt that's already on ECF, does NOT continue onto transfer journey" do
      when_i_navigate_to_participants_dashboard
      when_i_click_to_add_a_new_ect_or_mentor
      then_i_should_be_on_the_who_to_add_page

      when_i_select_to_add_a "A new ECT"
      when_i_click_on_continue
      then_i_am_taken_to_the_what_we_need_from_you_page

      when_i_click_on_continue
      then_i_am_taken_to_add_ect_name_page

      when_i_add_ect_or_mentor_name
      when_i_click_on_continue
      then_i_am_taken_to_add_teachers_trn_page

      when_i_add_the_trn
      when_i_click_on_continue
      then_i_am_taken_to_add_date_of_birth_page

      when_i_add_a_date_of_birth
      when_i_click_on_continue
      then_i_am_taken_to_are_they_a_transfer_page

      when_i_select "No"
      when_i_click_on_continue
      then_i_am_taken_to_the_cannot_add_page_same_school
    end
  end

  context "When participant already on ECF from a different school" do
    before do
      given_a_participant_from_a_different_school_is_already_on_ecf
    end

    scenario "Induction tutor tries to add ppt that's already on ECF, redirects to transfer journey" do
      when_i_navigate_to_participants_dashboard
      when_i_click_to_add_a_new_ect_or_mentor
      then_i_should_be_on_the_who_to_add_page

      when_i_select_to_add_a "A new ECT"
      when_i_click_on_continue
      then_i_am_taken_to_the_what_we_need_from_you_page

      when_i_click_on_continue
      then_i_am_taken_to_add_ect_name_page

      when_i_add_ect_or_mentor_name
      when_i_click_on_continue
      then_i_am_taken_to_add_teachers_trn_page

      when_i_add_the_trn
      when_i_click_on_continue
      then_i_am_taken_to_add_date_of_birth_page

      when_i_add_a_date_of_birth
      when_i_click_on_continue
      then_i_am_taken_to_are_they_a_transfer_page

      when_i_select "Yes"
      when_i_click_on_continue
      then_i_am_taken_to_teacher_start_date_page

      when_i_add_a_start_date
      when_i_click_on_continue
      then_i_am_taken_to_add_ect_or_mentor_email_page

      when_i_add_ect_or_mentor_email
      when_i_click_on_continue
      then_i_am_taken_to_choose_mentor_in_transfer_page

      when_i_select_a_mentor
      when_i_click_on_continue
      then_i_am_taken_to_the_teachers_current_programme_page

      when_i_select "Yes"
      when_i_click_on_continue

      then_i_am_taken_to_check_details_page
      when_i_click_confirm_and_add

      then_i_should_be_on_the_complete_page
    end

    scenario "Induction tutor tries to add ppt that's already on ECF, does NOT continue onto transfer journey" do
      when_i_navigate_to_participants_dashboard
      when_i_click_to_add_a_new_ect_or_mentor
      then_i_should_be_on_the_who_to_add_page

      when_i_select_to_add_a "A new ECT"
      when_i_click_on_continue
      then_i_am_taken_to_the_what_we_need_from_you_page

      when_i_click_on_continue
      then_i_am_taken_to_add_ect_name_page

      when_i_add_ect_or_mentor_name
      when_i_click_on_continue
      then_i_am_taken_to_add_teachers_trn_page

      when_i_add_the_trn
      when_i_click_on_continue
      then_i_am_taken_to_add_date_of_birth_page

      when_i_add_a_date_of_birth
      when_i_click_on_continue
      then_i_am_taken_to_are_they_a_transfer_page

      when_i_select "No"
      when_i_click_on_continue
      then_i_am_taken_to_the_cannot_add_page_different_school
    end
  end
end
