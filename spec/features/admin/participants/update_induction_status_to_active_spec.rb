# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_steps"

RSpec.feature "Super user admins should be able to update participants induction status to active", js: true, rutabaga: false do
  include ParticipantSteps

  context "when super user admin" do
    before do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_i_sign_in_as_a_super_user_admin
      and_i_have_added_an_ect
    end

    scenario "A super user admin can change induction statuses from withdrawn to active" do
      given_the_ect_has_withdrawn_induction_status
      when_i_visit_the_training_page_for_participant @participant_profile_ect

      and_i_click_on_change_induction_status
      then_i_should_be_on_the_edit_induction_status_page

      when_i_click_on_confirm
      and_i_should_see_the_participant_training
      and_a_new_induction_record_should_be_created
      and_admin_should_be_shown_a_success_message
      and_i_should_see_the_induction_statuses_are_active
    end

    scenario "A super user admin can change induction statuses from leaving to active" do
      given_the_ect_has_leaving_induction_status
      when_i_visit_the_training_page_for_participant @participant_profile_ect

      and_i_click_on_change_induction_status
      then_i_should_be_on_the_edit_induction_status_page

      when_i_click_on_confirm
      and_i_should_see_the_participant_training
      and_admin_should_be_shown_a_success_message
      and_i_should_see_the_induction_statuses_are_active
    end
  end

  context "when admin" do
    before do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      given_i_sign_in_as_an_admin_user
      and_i_have_added_an_ect
    end

    scenario "A super user admin can change induction statuses from withdrawn to active" do
      given_the_ect_has_withdrawn_induction_status
      when_i_visit_the_training_page_for_participant @participant_profile_ect
      then_i_should_not_see_the_change_induction_status_link
    end
  end
end
