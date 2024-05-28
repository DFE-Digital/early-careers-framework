# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adding mentor", js: true do
  include ManageTrainingSteps

  before do
    inside_registration_window do
      given_there_is_a_school_that_has_chosen_cip
      given_there_is_a_school_that_has_chosen_fip_for_current_and_next_cohorts_and_partnered
      set_participant_data
      set_dqt_validation_result
    end
  end

  scenario "Induction tutor adds a new mentor to current providers" do
    inside_registration_window do
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
      then_i_am_taken_to_mentor_added_confirmation_page

      when_i_click_on "View your mentors"
      then_i_see_the_mentor_name
      and_the_mentor_has_been_added_to_the_next_cohort
    end
  end

  def and_the_mentor_has_been_added_to_the_next_cohort
    expect(@school.mentor_profiles.last.school_cohort).to eq(@school_cohort_next)
  end

  def set_participant_data
    @participant_data = {
      trn: "1234567",
      full_name: "Sally Mentor",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "AB123456A",
      start_date: nil,
      start_term: nil,
    }
  end
end
