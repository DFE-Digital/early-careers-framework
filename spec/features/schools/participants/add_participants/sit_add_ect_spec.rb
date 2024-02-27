# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adding themself as ECT", js: true do
  include ManageTrainingSteps

  before do
    outside_auto_assignment_window do
      given_there_is_a_school_that_has_chosen_cip
      set_participant_data
      given_there_is_a_school_that_has_chosen_fip_and_partnered
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click_on(Cohort.current.description)
      then_i_am_taken_to_fip_induction_dashboard

      set_dqt_validation_result
    end
  end

  scenario "SIT aborts process as it can't add themself as ECT" do
    outside_auto_assignment_window do
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

      when_i_add_ect_or_mentor_email(email: @induction_coordinator_profile.user.email)
      when_i_click_on_continue
      then_i_am_taken_to_you_cant_add_yourself_as_ect_page

      when_i_choose_to_cancel
      and_i_click_on_continue
      then_i_am_taken_to_manage_your_training_page
    end
  end

  scenario "SIT chooses to add themself as Mentor instead" do
    outside_auto_assignment_window do
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

      when_i_add_ect_or_mentor_email(email: @induction_coordinator_profile.user.email)
      when_i_click_on_continue
      then_i_am_taken_to_you_cant_add_yourself_as_ect_page

      when_i_choose_to_add_myself_as_mentor
      and_i_click_on_continue
      then_i_am_taken_to_add_yourself_as_mentor_confirmation_page

      when_i_click_on_confirm
      then_i_am_taken_to_sit_mentor_start_training_page

      when_i_choose_summer_term_this_cohort
      and_i_click_on_continue
      then_i_am_taken_to_choose_mentor_partnership_page

      when_i_choose_current_providers
      and_i_click_on_continue
      then_i_am_taken_to_check_answers_page

      when_i_click_confirm_and_add
      then_i_am_taken_to_yourself_as_mentor_confirmation_page

      when_i_click_on_view_mentors
      then_i_see_the_participant_name
    end
  end
end
