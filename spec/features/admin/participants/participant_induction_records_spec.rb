# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin should be able to see the participant's induction records", js: true, rutabaga: false do
  include ParticipantSteps

  before { setup_participant }

  scenario "I should be able to see the list of induction records" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_tab("Induction records")
    then_i_should_be_on_the_participant_induction_records_page
    and_i_should_see_the_participant_induction_records
  end
end
