# frozen_string_literal: true

require "rails_helper"
require_relative "../dashboard/manage_training_steps"

RSpec.describe "Update participants details", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    then_i_should_see_the_fip_induction_dashboard
    when_i_click_add_your_early_career_teacher_and_mentor_details
    when_i_click_on_add_a_new_ect_or_mentor_link
    then_i_am_taken_to_add_your_ect_and_mentors_page
  end

  scenario "Induction tutor can change ECT / mentor name from check details page" do
    when_i_select_add_ect
    and_select_continue
    then_i_am_taken_to_add_ect_name_page
    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    when_i_add_ect_or_mentor_email
    and_select_continue
    then_i_am_taken_to_check_details_page

    when_i_select_change_name
    then_i_am_taken_to_add_ect_name_page
    when_i_add_ect_or_mentor_updated_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_updated_email_page
    and_select_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_updated_name
  end

  scenario "Induction tutor can change ECT / mentor email from check details page" do
    when_i_select_add_ect
    and_select_continue
    then_i_am_taken_to_add_ect_name_page
    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page
    when_i_add_ect_or_mentor_email
    and_select_continue
    then_i_am_taken_to_check_details_page

    when_i_select_change_email
    then_i_am_taken_to_add_ect_or_mentor_email_page
    when_i_add_ect_or_mentor_updated_email
    and_select_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_updated_email
  end

  scenario "Induction tutor can change ECTs mentor from check details page" do
    and_i_have_added_a_mentor
    when_i_select_add_ect
    and_select_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_or_mentor_name
    and_select_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email
    and_select_continue
    then_i_am_taken_to_add_mentor_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Induction tutor chooses mentor for ECT"

    when_i_select_a_mentor
    and_select_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_mentor_name

    when_i_select_change_mentor
    then_i_am_taken_to_add_mentor_page
    when_i_select_assign_mentor_later
    and_select_continue
    then_i_am_taken_to_check_details_page
    then_i_can_view_assign_mentor_later_status
  end
end
