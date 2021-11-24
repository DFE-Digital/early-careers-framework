# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.feature "School Tutors should be abled to manage schools", type: :feature, js: true, rutabaga: false do
  include ManageTrainingSteps

  scenario "Change school" do
    given_there_are_multiple_schools_and_an_induction_coordinator
    and_i_am_signed_in_as_an_induction_coordinator_for_multiple_schools
    then_i_am_on_schools_page
    and_i_should_see_multiple_schools
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Induction Coordinator Select School"

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
    and_percy_should_be_sent_a_snapshot_named "School Cohorts with Breadcrumbs"
  end

  scenario "view withdrawn participants" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    then_they_have_been_withdrawn_by_the_provider

    when_i_visit_manage_training_dashboard
    then_i_am_taken_to_fip_induction_dashboard
    and_it_should_show_the_withdrawn_participant
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Withdrawn participant shown on dashboard"

    when_i_click_on_details
    then_i_am_taken_to_view_details_page
    and_it_should_not_allow_a_sit_edit_the_participant_details
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant details without change links"
  end
end
