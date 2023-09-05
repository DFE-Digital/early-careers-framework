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
  end

  scenario "FIP Induction Coordinator without training provider" do
    given_there_is_a_school_that_has_chosen_fip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_fip_induction_dashboard_without_partnership_details
    then_the_page_should_be_accessible
  end

  scenario "Change induction programme to FIP" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
    and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE",
                                                        "Deliver your own programme using DfE accredited materials"],
                                               choice: "Use a training provider, funded by the DfE")

    expect(page).to have_text "You’ve submitted your training information"
  end
end
