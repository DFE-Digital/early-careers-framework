# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.feature "School Tutors should be abled to manage schools", type: :feature, js: true, rutabaga: false do
  include ManageTrainingSteps

  scenario "Change school" do
    given_there_are_multiple_schools
    and_i_am_signed_in_as_an_induction_coordinator_for_multiple_schools
    and_i_am_on_schools_page
    then_i_should_see_multiple_schools
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Induction Coordinator Select School"

    given_i_click_on_test_school_1
    then_i_should_be_on_school_cohorts_1_page
    and_i_should_see_school_1_data
    and_the_page_should_be_accessible

    given_i_click_on_manage_your_schools
    and_i_am_on_schools_page
    then_i_should_see_multiple_schools

    given_i_click_on_test_school_2
    then_i_should_be_on_school_cohorts_2_page
    and_i_should_see_school_2_data
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "School Cohorts with Breadcrumbs"
  end
end
