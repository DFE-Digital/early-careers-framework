# frozen_string_literal: true

require "rails_helper"
require_relative "../dashboard/manage_training_steps"

RSpec.describe "Add participants", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  scenario "Induction tutor can add new ECT participant" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect_or_mentor
    then_i_should_see_the_fip_induction_dashboard

    when_i_click_add_your_early_career_teacher_and_mentor_details
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT and mentors"

    when_i_select_add_ect
    and_select_continue
    then_i_am_taken_to_add_ect_name_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT name"

    when_i_add_ect_name
    and_select_continue
    then_i_am_taken_to_add_ect_email_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add ECT email"

    when_i_add_ect_email
    and_select_continue
  end

  scenario "Induction tutor can add new Mentor participant" do
  end

  scenario "Induction tutor can add themselves as a mentor" do
  end
end
