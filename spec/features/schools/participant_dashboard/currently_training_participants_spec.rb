# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Manage currently training participants", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
  end

  context "Induction coordinators can view and manage participants currently training" do
    before do
      and_i_have_added_a_mentor
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_a_training_ect_with_mentor
      and_i_have_added_another_training_ect_with_mentor
      and_i_have_added_an_eligible_ect_without_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
      given_i_am_taken_to_the_induction_dashboard
      when_i_navigate_to_participants_dashboard
    end

    scenario "Sorted by mentor name" do
      then_i_see_the_participants_sorted_by_mentor

      when_i_click_on_the_participants_name "Billy Mentor"
      then_i_am_taken_to_view_mentor_details_page
    end

    scenario "Sorted by induction start date" do
      when_i_sort_participants_by_induction_start_date
      then_i_see_the_participants_sorted_by_induction_start_date

      when_i_click_on_the_participants_name "Training ECT With-mentor"
      then_i_am_taken_to_view_ect_details_page
    end
  end
end
