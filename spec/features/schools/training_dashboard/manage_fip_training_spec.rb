# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage FIP training", js: true, travel_to: Time.zone.local(2021, 9, 17, 16, 15, 0) do
  include ManageTrainingSteps

  scenario "FIP Induction Coordinator with training provider" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_am_taken_to_fip_induction_dashboard
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "FIP dashboard with partnership"

    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page

    when_i_visit_manage_training_dashboard
    when_i_click_on_view_details
    then_i_am_taken_to_fip_programme_choice_info_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "FIP programme info"
  end

  scenario "FIP Induction Coordinator without training provider" do
    given_there_is_a_school_that_has_chosen_fip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_fip_induction_dashboard_without_partnership_details
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "FIP dashboard without partnership"

    when_i_click_on_sign_up
    then_i_am_taken_to_sign_up_to_training_provider_page
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named "Sign up to training provider"
  end

  scenario "Change induction programme to FIP" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
    and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE (full induction programme)",
                                                        "Deliver your own programme using DfE accredited materials (core induction programme)"],
                                               choice: "Use a training provider, funded by the DfE (full induction programme)",
                                               snapshot: "FIP - change programme options")

    expect(page).to have_text "Training programme confirmed"
    expect(page).to have_text "choose one of the 6 DfE-funded training providers as soon as possible"
  end
end
