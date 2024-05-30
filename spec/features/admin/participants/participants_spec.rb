# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin finding participants", js: true, rutabaga: false do
  include ParticipantSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    when_i_visit_admin_participants_dashboard
  end

  scenario "Viewing a list of participants" do
    @page = Pages::AdminSupportParticipantList.load

    then_i_should_see_a_list_of_participants
  end

  scenario "Searching participants" do
    @page = Pages::AdminSupportParticipantList.load

    then_i_see_the_search_bar

    when_i_search_for_participant "Sally Teacher"
    then_the_search_results_are_displayed

    when_i_search_for_participant "random keyword"
    then_the_search_results_are_empty
  end

  def when_i_search_for_participant(keyword)
    @page.search_field.send_keys(keyword)
    @page.search_button.click
  end

  def then_i_see_the_search_bar
    expect(@page).to have_search_field
    expect(@page).to have_search_button
  end

  def then_the_search_results_are_displayed
    expect(@page).to have_search_results
    expect(@page.search_results.first.full_name.text).to eq("Sally Teacher")
  end

  def then_the_search_results_are_empty
    expect(@page).to_not have_search_results
  end
end
