# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Admin should be able to see the participant's induction records", js: true, rutabaga: false do
  include ParticipantSteps

  scenario "I should be able to see the list of induction records" do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    and_i_have_added_an_npq_profile
    when_i_visit_admin_participants_dashboard
    then_i_should_see_a_list_of_participants

    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_tab("Training")
    then_i_should_be_on_the_participant_training_page
    and_i_should_see_the_participant_induction_records
    and_the_page_title_should_be("Sally Teacher - Training details")
  end
end
