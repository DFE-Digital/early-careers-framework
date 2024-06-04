# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adding an ECT", js: true do
  include ManageTrainingSteps

  before do
    inside_auto_assignment_window do
      given_there_is_a_school_that_has_chosen_cip
      given_there_is_a_school_that_has_chosen_fip_for_previous_and_current_cohort_and_partnered
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_have_added_a_mentor
      and_i_click_on(Cohort.current.description)
      then_i_am_taken_to_fip_induction_dashboard
      set_participant_data
    end
  end

  scenario "when target cohort payments are frozen" do
    inside_auto_assignment_window do
      # induction start date is in the previous cohort, which has had payments frozen
      @participant_data[:start_date] = Date.new(Cohort.previous.start_year, 9, 1)
      set_dqt_validation_result
      # @cohort here refers to the previous cohort
      @cohort.update!(payments_frozen_at: 1.day.ago)

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

      when_i_select_a_mentor
      when_i_click_on_continue

      when_i_click_confirm_and_add
      then_i_see_confirmation_that_the_participant_has_been_added
      and_the_participant_has_been_added_to_the_next_cohort
      and_the_mentors_cohort_has_not_changed
    end
  end

  scenario "when the mentor's cohort payments are frozen" do
    inside_auto_assignment_window do
      # induction start date is in the current cohort
      @participant_data[:start_date] = Date.new(Cohort.current.start_year, 9, 1)
      set_dqt_validation_result
      # @cohort here refers to the mentor's cohort which is the previous cohort
      @cohort.update!(payments_frozen_at: 1.day.ago)

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

      when_i_select_a_mentor
      when_i_click_on_continue

      when_i_click_confirm_and_add
      then_i_see_confirmation_that_the_participant_has_been_added
      and_the_participant_has_been_added_to_the_next_cohort
      and_the_mentors_cohort_is_the_same_as_the_ects_cohort
    end
  end

  def then_i_see_confirmation_that_the_participant_has_been_added
    expect(page).to have_content("#{@participant_data[:full_name]} has been added as an ECT")
  end

  def and_the_participant_has_been_added_to_the_next_cohort
    expect(ParticipantProfile::ECT.last.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
  end

  def and_the_mentors_cohort_has_not_changed
    expect(ParticipantProfile::Mentor.last.school_cohort.cohort).to eq(Cohort.previous)
  end

  def and_the_mentors_cohort_is_the_same_as_the_ects_cohort
    expect(ParticipantProfile::Mentor.last.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
  end
end
