# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage CIP training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "CIP Induction Mentor without materials chosen" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_cip_induction_dashboard

    when_i_click_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_add_new_ect_or_mentor_page
    and_then_return_to_dashboard

    when_i_click_on_view_details
    then_i_am_taken_to_cip_programme_choice_info_page
  end

  scenario "CIP Induction Mentor with materials chosen" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_cip_induction_dashboard

    when_i_click_on_add_materials
    then_i_am_taken_to_course_choice_page
    when_i_select_materials
    and_i_am_taken_to_course_confirmed_page
    and_then_return_to_dashboard
    then_i_can_view_the_added_materials
  end
end
