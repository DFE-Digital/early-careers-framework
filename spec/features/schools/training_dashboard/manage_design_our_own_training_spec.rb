# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage Design Our Own training", js: true do
  include ManageTrainingSteps

  scenario "Design Our Own Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_design_our_own_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_design_our_own_induction_dashboard
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Design Our Own dashboard"
  end

  scenario "Change induction programme to Design Your Own" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "no_early_career_teachers")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Programme No early career teachers for this cohort")
    and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE (full induction programme)",
                                                        "Deliver your own programme using DfE accredited materials (core induction programme)"],

                                               choice: "Design and deliver your own programme based on the Early Career Framework (ECF)",
                                               snapshot: "Design Your Own - change programme")

    expect(page).to have_text "design a 2-year programme of support and training that covers every ‘learn that’ and ‘learn how to’ statement in the Early Career Framework (ECF)"
    expect(page).to have_text "Training programme confirmed"
  end
end
