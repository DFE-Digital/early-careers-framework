# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage No ECT training", js: true, travel_to: Date.new(2022, 3, 1) do
  include ManageTrainingSteps

  scenario "Manage No ECT Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_no_ect_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_no_ect_induction_dashboard
    then_the_page_should_be_accessible

    when_i_click_on_tell_us_if_this_has_changed
    then_i_am_taken_to_setup_my_programme
    then_the_page_should_be_accessible
  end

  scenario "Change induction programme to No ECTs" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
    then_i_see_the_change_programme_page
    then_i_navigate_the_cohort_setup_wizard_before_choosing(labels: ["Use a training provider, funded by the DfE",
                                                                     "Deliver your own programme using DfE-accredited materials"],
                                                            choice: "We do not expect any early career teachers to join")
  end
end
