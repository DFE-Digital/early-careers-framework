# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage No ECT training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "Manage No ECT Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_no_ect_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_no_ect_induction_dashboard
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "No ECT dashboard"

    when_i_select_change
    then_i_am_taken_to_change_how_you_run_programme_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "No ECT training info"
  end

  scenario "Change induction programme to ECT training" do
    school_cohort = create :school_cohort, induction_programme_choice: "design_our_own", school: create(:school, name: "Test School")

    sign_in_as create(:induction_coordinator_profile, schools: [school_cohort.school]).user
    expect(page).to have_text("Design and deliver your own programme based on the Early Career Framework (ECF)")
    click_on "Change induction programme choice"

    expect(page).to have_text "Change how you run your programme"
    expect(page).to be_accessible
    click_on "Check the other options available"

    expect(page).to have_text "How do you want to run your training"
    expect(page).to have_selector :label, text: "Use a training provider, funded by the DfE (full induction programme)"
    expect(page).to have_selector :label, text: "Deliver your own programme using DfE accredited materials (core induction programme)"
    expect(page).to be_accessible
    page.percy_snapshot "Design Our Own - change programme options"

    choose "We don’t expect to have any early career teachers starting in 2021"
    click_on "Continue"

    expect(page).to have_text "Confirm your induction programme"
    click_on "Confirm"

    expect(page).to have_text "Training programme confirmed"
    expect(page).to have_text "Your school will not receive any more messages about statutory inductions for ECTs until the next academic year."
  end
end
