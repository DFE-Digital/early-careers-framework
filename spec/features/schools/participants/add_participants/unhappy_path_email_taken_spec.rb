# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", js: true, early_in_cohort: true do
  include ManageTrainingSteps

  before do
    inside_auto_assignment_window do
      given_there_is_a_school_that_has_chosen_fip_and_partnered
      and_i_have_added_an_ect
      and_i_have_added_a_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(@cohort.description)
      then_i_am_taken_to_fip_induction_dashboard
      set_dqt_validation_result
    end
  end

  scenario "Induction tutor cannot add existing ECT" do
    inside_auto_assignment_window do
      when_i_navigate_to_ect_dashboard
      when_i_click_to_add_a_new_ect
      then_i_should_be_on_the_who_to_add_page

      when_i_select_to_add_a "ECT"
      when_i_click_on_continue
      then_i_am_taken_to_the_what_we_need_to_know_about_this_ect_page

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

      when_i_add_ect_or_mentor_email_that_already_exists
      when_i_click_on_continue
      then_i_am_taken_to_email_already_taken_page
      then_the_page_should_be_accessible
    end
  end
end
