# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin should be able to see the participant's current school", js: true, rutabaga: false do
  include ParticipantSteps

  before { setup_participant }

  scenario "I should be able to see the current school's information" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_tab("School")
    then_i_should_be_on_the_participant_school_page
    and_i_should_see_the_current_schools_details
    and_the_page_title_should_be("Sally Teacher - School")
  end

  context "when the participant has a mentor" do
    before { given_the_mentor_is_mentoring_the_ect }

    scenario "the mentor's name should be a link to their profile" do
      when_i_click_on_the_participants_name "Sally Teacher"
      when_i_click_on_tab("School")
      and_the_mentors_name_should_be_a_link_to_their_profile
    end
  end
end
