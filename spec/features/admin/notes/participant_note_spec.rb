# frozen_string_literal: true

require "rails_helper"
require_relative "../participants/participant_steps"

RSpec.feature "Admin can add notes to a participants record in the admin console", js: true, rutabaga: false do
  include ParticipantSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    when_i_visit_admin_participants_dashboard
    then_i_should_see_a_list_of_participants
  end

  scenario "Admin is adding a note on an ECTs profile" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details
    and_the_page_should_have_no_notes

    when_i_click_on_add_notes
    then_i_should_be_on_the_edit_notes_page

    when_i_add_notes_to_the_participants_record
    click_on "Save"
    then_i_should_see_the_ects_details
    and_the_notes_that_have_been_added
  end

  scenario "Admin is adding a note on an Mentors profile" do
    when_i_click_on_the_participants_name "Billy Mentor"
    then_i_should_see_the_mentors_details
    and_the_page_should_have_no_notes

    when_i_click_on_add_notes
    then_i_should_be_on_the_edit_notes_page

    when_i_add_notes_to_the_participants_record
    click_on "Save"
    then_i_should_see_the_mentors_details
    and_the_notes_that_have_been_added
  end
end
