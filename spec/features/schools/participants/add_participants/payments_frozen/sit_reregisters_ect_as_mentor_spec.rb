# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adding mentor", js: true do
  include ManageTrainingSteps

  scenario "Induction tutor re-registers an ECT as mentor when cohort is frozen" do
    inside_auto_assignment_window do
      given_there_is_a_school_that_has_chosen_cip
      given_there_is_a_school_that_has_chosen_fip_for_previous_and_current_cohort_and_partnered
      and_i_have_added_an_ect

      and_i_am_adding_a_participant_with_an_induction_start_date_in_the_previous_cohort
      and_the_previous_cohort_is_frozen

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
      and_the_mentor_has_been_added_to_the_next_cohort
    end
  end

  scenario "Induction tutor re-registers an ECT as mentor, inside registration period, when cohort is frozen" do
    inside_registration_window do
      given_there_is_a_school_that_has_chosen_cip
      given_there_is_a_school_that_has_chosen_fip_for_current_and_next_cohorts_and_partnered
      and_i_have_added_an_ect

      and_i_am_adding_a_participant_with_an_induction_start_date_in_the_previous_cohort
      and_the_previous_cohort_is_frozen

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
      and_the_mentor_has_been_added_to_the_next_cohort
    end
  end

  def when_i_complete_all_the_wizard_steps
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
    then_i_am_taken_to_choose_mentor_partnership_page

    when_i_choose_current_providers
    and_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
  end

  def and_i_am_adding_a_participant_with_an_induction_start_date_in_the_previous_cohort
    set_participant_data
    @participant_data[:start_date] = Date.new(Cohort.previous.start_year, 9, 1)
    set_dqt_validation_result
  end

  def and_the_previous_cohort_is_frozen
    @cohort.update!(payments_frozen_at: 1.day.ago)
  end

  def and_the_mentor_has_been_added_to_the_next_cohort
    expect(ParticipantProfile::Mentor.last.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
  end
end
