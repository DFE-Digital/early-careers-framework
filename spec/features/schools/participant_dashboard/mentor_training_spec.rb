# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Mentor training dashboard", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
  end

  context "When a mentor has completed their training" do
    before do
      and_i_have_added_a_mentor_who_completed_training
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
      given_i_am_taken_to_the_induction_dashboard
      when_i_navigate_to_mentors_dashboard
    end

    scenario "SIT can see the mentor training status as completed" do
      when_i_click_on_the_participants_name "Billy Mentor"
      then_i_am_taken_to_view_mentor_details_page
      and_i_see_the_status_training_completed
    end
  end

  context "When a mentor has not completed their training" do
    before do
      and_i_have_added_a_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
      given_i_am_taken_to_the_induction_dashboard
      when_i_navigate_to_mentors_dashboard
    end

    scenario "SIT doesn't see the mentor training info" do
      when_i_click_on_the_participants_name "Billy Mentor"
      then_i_am_taken_to_view_mentor_details_page
      and_i_dont_see_the_status_training
    end
  end
end
