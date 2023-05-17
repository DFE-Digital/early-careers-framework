# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage Design Our Own training", :with_default_schedules, js: true do
  include ManageTrainingSteps

  scenario "Design Our Own Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_design_our_own
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_view_the_design_our_own_induction_dashboard
    and_the_page_should_be_accessible
  end

  scenario "Change induction programme to Design Your Own" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "no_early_career_teachers")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_can_change_the_programme_to_design_your_own
  end
end
