# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin should be able to update participants details", js: true, rutabaga: false do
  include ParticipantSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    when_i_visit_admin_participants_dashboard
    then_i_should_see_a_list_of_participants
  end

  scenario "Admin can edit a participants name" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_change_name
    then_i_should_be_on_the_edit_name_page

    when_i_update_the_name_with ""
    and_i_click_on_continue
    then_i_should_receive_a_missing_name_error_message

    when_i_update_the_name_with "Sandra Teacher"
    and_i_click_on_continue
    then_i_should_be_in_the_admin_participants_dashboard
    and_admin_should_be_shown_a_success_message
    and_the_page_should_have_the_updated_name "Sandra Teacher"
  end

  scenario "Admin can edit a participants email" do
    when_i_click_on_the_participants_name "Billy Mentor"
    then_i_should_see_the_mentors_details

    when_i_click_on_change_email
    then_i_should_be_on_the_edit_email_page

    when_i_update_the_email_with "invalid@email"
    and_i_click_on_continue
    then_i_should_receive_a_invalid_email_error_message

    when_i_update_the_email_with ""
    and_i_click_on_continue
    then_i_should_receive_a_missing_email_error_message

    when_i_update_the_email_with @participant_profile_ect.user.email
    and_i_click_on_continue
    then_i_should_receive_an_email_already_taken_error_message

    when_i_update_the_email_with "billy@mentor-example.com"
    and_i_click_on_continue
    then_i_should_be_in_the_admin_participants_dashboard
    and_admin_should_be_shown_a_success_message

    when_i_click_on_the_participants_name "Billy Mentor"
    then_the_participants_email_should_have_updated "billy@mentor-example.com"
  end
end
