# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage Design Our Own training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "Design Our Own Induction Coordinator" do
    given_there_is_a_school_that_has_chosen_design_our_own_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_design_our_own_induction_dashboard
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Design Our Own dashboard"

    when_i_select_view_details
    then_i_am_taken_to_design_our_own_course_programme_choice_info_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Design Our Own programme info"
  end
end
