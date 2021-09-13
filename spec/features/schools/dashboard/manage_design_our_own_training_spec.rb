# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage Design Our Own training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "Design Our Own Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_design_our_own_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_no_ect_induction_dashboard
    when_i_select_view_details
    then_i_am_taken_to_no_ect_training_info_page
  end
end
