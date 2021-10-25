# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage CIP training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "CIP Induction Mentor without materials chosen" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_cip_induction_dashboard
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "CIP induction dashboard without materials"

    when_i_click_add_your_early_career_teacher_and_mentor_details
    when_i_am_taken_to_roles_page
    and_then_return_to_dashboard

    when_i_click_on_view_details
    then_i_am_taken_to_cip_programme_choice_info_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "CIP programme info"
  end

  scenario "CIP Induction Mentor with materials chosen" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_cip_induction_dashboard

    when_i_click_on_add_materials
    then_i_am_taken_to_course_choice_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Course choice"

    when_i_select_materials
    and_i_am_taken_to_course_confirmed_page
    and_then_return_to_dashboard
    then_i_can_view_the_added_materials
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "CIP induction dashboard with materials"
  end

  scenario "CIP Induction Mentor who has not added ECT or mentors" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_add_your_ect_and_mentor_link
  end

  scenario "CIP Induction Mentor who has added ECT or mentors" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_have_added_an_ect
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_view_your_ect_and_mentor_link
  end

  scenario "Change induction programme to CIP" do
    given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
    and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE (full induction programme)",
                                                        "Deliver your own programme using DfE accredited materials (core induction programme)",
                                                        "We don’t expect to have any early career teachers starting in 2021"],
                                               choice: "Deliver your own programme using DfE accredited materials (core induction programme)",
                                               snapshot: "Design Our Own - change programme options")

    expect(page).to have_text "compare and choose which DfE-accredited materials you want to use"
    expect(page).to have_text "Training programme confirmed"
  end
end
