# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin should be able to see the participant's history", js: true, rutabaga: false do
  include ParticipantSteps

  before { setup_participant }

  scenario "I should be able to see the current school's information" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_tab("History")
    then_i_should_be_on_the_participant_history_page
    and_i_should_see_the_participant_history
    and_the_page_title_should_be("Sally Teacher - History")
  end
end
