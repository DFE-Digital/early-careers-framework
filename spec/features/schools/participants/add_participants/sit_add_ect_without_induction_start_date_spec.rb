# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "SIT adds ECT participant with no induction start date", js: true do
  include ManageTrainingSteps

  before do
    inside_registration_window do
      set_participant_data
      given_there_is_a_school_that_has_chosen_fip_for_current_and_next_cohorts_and_partnered
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click_on(Cohort.current.description)
      then_i_am_taken_to_fip_induction_dashboard

      set_dqt_validation_result
    end
  end

  scenario "when inside the registration period" do
    inside_registration_window do
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

      when_i_click_confirm_and_add
      then_i_am_taken_to_the_confirmation_page
      and_the_participant_has_been_added_to_the_next_cohort
    end
  end

  scenario "when outside the registration period" do
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

      when_i_add_ect_or_mentor_email(email: @participant_data[:email])
      when_i_click_on_continue

      then_i_see_i_cannot_add_participant_yet
    end
  end

  scenario "when training setup is needed" do
    inside_registration_window do
      @school_cohort_next.update!(induction_programme_choice: :design_our_own)

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

      then_i_see_that_training_setup_is_needed
    end
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(page).to have_content("#{@participant_data[:full_name]} has been added as an ECT")
  end

  def and_the_participant_has_been_added_to_the_next_cohort
    expect(@school.ecf_participant_profiles.last.school_cohort).to eq(@school_cohort_next)
  end

  def set_participant_data
    @participant_data = {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "AB123456A",
      start_date: nil,
    }
  end
end
