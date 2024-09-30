# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"
require_relative "./common_steps"

RSpec.describe "SIT adding mentor", js: true, early_in_cohort: true do
  include ManageTrainingSteps

  scenario "Induction tutor re-registers an ECT as mentor when cohort is frozen" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen
    and_i_have_added_an_ect

    given_there_is_a_sit
    when_i_sign_in_as_sit
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_mentors_dashboard
    and_i_click_to_add_a_new_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_complete_all_the_wizard_steps
    then_i_am_taken_to_mentor_added_confirmation_page
    and_the_mentor_has_been_added_to_the_active_registration_cohort
  end

  scenario "Induction tutor re-registers an ECT as mentor, inside registration period, when cohort is frozen" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen
    and_i_have_added_an_ect

    given_there_is_a_sit
    when_i_sign_in_as_sit
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_mentors_dashboard
    and_i_click_to_add_a_new_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_complete_all_the_wizard_steps
    then_i_am_taken_to_mentor_added_confirmation_page
    and_the_mentor_has_been_added_to_the_active_registration_cohort
  end
end
