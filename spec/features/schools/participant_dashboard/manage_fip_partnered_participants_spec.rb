# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Manage FIP partnered participants with no change of circumstances", js: true, with_feature_flags: { eligibility_notifications: "active" } do
  include ManageTrainingSteps

  context "inactive change of circumstances flag" do
    it_behaves_like "manage fip participants example"
  end
end

RSpec.describe "Manage FIP partnered participants with change of circumstances", js: true, with_feature_flags: { eligibility_notifications: "active", change_of_circumstances: "active" } do
  include ManageTrainingSteps

  context "active change of circumstances flag" do
    it_behaves_like "manage fip participants example"
  end

  context "transferring participants" do
    before do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_i_am_signed_in_as_an_induction_coordinator
    end

    xcontext "in to a school" do
      before { and_i_have_added_a_transferring_in_participant }

      scenario "Induction coordinators can view and manage participant" do
        given_i_am_taken_to_fip_induction_dashboard
        when_i_navigate_to_participants_dashboard
        then_i_can_view_transferring_in_participants

        when_i_click_on_the_participants_name "Transferring in participant"
        then_i_am_taken_to_view_details_page
      end
    end

    xcontext "out of a school" do
      before { and_i_have_a_transferring_out_participant }

      scenario "Induction coordinators can view and manage participant" do
        given_i_am_taken_to_fip_induction_dashboard
        when_i_navigate_to_participants_dashboard
        click_on "Moving school"
        then_i_can_view_transferring_out_participants
        and_they_have_an_end_date

        when_i_click_on_the_participants_name "Eligible ect"
        then_i_am_taken_to_view_details_page
      end
    end
  end

  context "participants that have transferred out" do
    before do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_i_have_a_transferred_out_participant
      and_i_am_signed_in_as_an_induction_coordinator
    end

    scenario "Induction coordinator can view participants that have completed their transfer out" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_participants_dashboard(action: "Add")
      click_on "Not training"
      then_i_can_view_transferred_from_your_school_participants

      when_i_click_on_the_participants_name "Eligible ect"
      then_i_am_taken_to_view_details_page
    end
  end

  scenario "withdrawn partnership shouldn't cause an error" do
    expect {
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered_but_challenged
      and_i_have_added_an_ect
      and_an_ect_has_been_withdrawn_by_the_provider
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_can_view_the_fip_induction_dashboard_without_partnership_details(displayed_value: "")
      when_i_navigate_to_participants_dashboard
      click_on "Not training"
    }.not_to raise_error
  end
end
