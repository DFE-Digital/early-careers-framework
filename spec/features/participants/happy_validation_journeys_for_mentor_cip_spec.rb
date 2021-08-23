# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_validation_steps"

RSpec.feature "Mentor participant validation journey for CIP induction", type: :feature, js: true, with_feature_flags: { participant_validation: "active" } do
  include ParticipantValidationSteps

  scenario "Participant validates their details" do
    given_there_is_a_school_that_has_chosen_cip_for_2021
    and_i_am_signed_in_as_a_mentor_participant
    then_i_should_see_the_do_you_know_your_trn_page

    when_i_select "Yes, I know my TRN"
    and_i_click "Continue"
    then_i_should_see_the_have_you_changed_your_name_page

    when_i_select "No, I have the same name"
    and_i_click "Continue"
    then_i_should_see_the_tell_us_your_details_page

    when_i_enter_the_participants_details
    and_i_click "Continue"
    then_i_should_see_the_confirm_details_page

    when_i_click_continue_to_proceed_with_validation
    then_i_should_see_the_complete_page_for_matched_cip_mentor_participant
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Participant Validation: Complete mentor CIP"
  end
end
