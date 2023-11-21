# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.feature "School Tutors should be able to manage schools", type: :feature, js: true, rutabaga: false do
  include ManageTrainingSteps

  scenario "Change school" do
    given_there_are_multiple_schools_and_an_induction_coordinator
    and_i_am_signed_in_as_an_induction_coordinator_for_multiple_schools
    then_i_am_on_schools_page
    and_i_should_see_multiple_schools
    and_the_page_should_be_accessible

    given_i_click_on_test_school_1
    then_i_should_be_on_school_cohorts_1_page
    and_i_should_see_school_1_data
    and_the_page_should_be_accessible

    given_i_click_on_manage_your_schools
    then_i_am_on_schools_page
    and_i_should_see_multiple_schools

    given_i_click_on_test_school_2
    then_i_should_be_on_school_cohorts_2_page
    and_i_should_see_school_2_data
    and_the_page_should_be_accessible
  end

  context "Multiple cohorts when the new cohort is open for registrations" do
    scenario "Start setting up the new cohort" do
      given_there_is_a_school_that_has_chosen_cip_for_previous_cohort
      travel_to Cohort.current.registration_start_date + 1.day do
        and_cohort_current_is_created
        and_i_am_signed_in_as_an_induction_coordinator
        then_i_am_on_the_what_we_need_to_know_page(previous_year: Cohort.next.start_year, current_year: Cohort.next.start_year + 1)
      end
    end
  end
end
