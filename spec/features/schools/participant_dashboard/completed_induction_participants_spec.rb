# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Manage currently training participants", js: true, mid_cohort: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
  end

  it "Induction coordinators can view and manage participants that have completed their induction" do
    and_i_have_added_a_mentor
    and_i_have_added_a_contacted_for_info_mentor
    and_i_have_added_a_contacted_for_info_ect_without_mentor
    and_i_have_added_an_eligible_ect_without_mentor
    and_my_ects_have_completed_their_induction
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click(Cohort.current.description)
    given_i_am_taken_to_the_induction_dashboard

    when_i_navigate_to_ect_dashboard
    then_i_see_the_ects_filter_with_counts(completed_induction: 2, currently_training: 0, no_longer_training: 0)
    when_i_filter_by("Completed induction (2)")
    then_i_see_the_participants_filtered_by("Completed Induction")
    and_i_see_ects_with_induction_completed_sorted_by_decreasing_completion_date

    when_i_click_on_the_participants_name "Eligible Without-mentor"
    then_i_am_taken_to_view_ect_details_page
    and_i_see_the_completion_status_tag
  end
end
