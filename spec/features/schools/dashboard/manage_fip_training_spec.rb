# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage FIP training", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "FIP Induction Coordinator with training provider" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    then_i_should_see_the_fip_induction_dashboard
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "FIP dashboard with partnership"

    when_i_click_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_add_new_ect_or_mentor_page
    and_then_return_to_dashboard

    when_i_click_on_view_details
    then_i_am_taken_to_fip_programme_choice_info_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "FIP programme info"
  end

  scenario "FIP Induction Coordinator without training provider" do
    given_there_is_a_school_that_has_chosen_fip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator

    then_i_should_see_the_fip_induction_dashboard_without_partnership_details
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "FIP dashboard without partnership"

    when_i_click_on_sign_up
    then_i_am_taken_to_sign_up_to_training_provider_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Sign up to training provider"
  end
end
