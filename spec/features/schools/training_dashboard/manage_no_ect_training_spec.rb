# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage No ECT training", js: true do
  include ManageTrainingSteps

  scenario "Manage No ECT Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_no_ect_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_no_ect_induction_dashboard
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "No ECT dashboard"

    when_i_click_on_change_programme
    then_i_am_taken_to_change_how_you_run_programme_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "No ECT training info"
  end

  scenario "Change induction programme to No ECTs" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
    and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE",
                                                        "Deliver your own programme using DfE accredited materials"],
                                               choice: "We don’t expect to have any early career teachers starting in 2021",
                                               snapshot: "Design Your Own - change programme options")

    expect(page).to have_text "You’ve submitted your training information"
    expect(page).to have_text "Your school will not receive any more messages about statutory inductions for ECTs until the next academic year."
  end
end
