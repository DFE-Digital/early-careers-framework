# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.xdescribe "Manage FIP unpartnered participants", js: true, with_feature_flags: { eligibility_notifications: "active" } do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021
    and_i_am_signed_in_as_an_induction_coordinator
  end

  context "Ineligible ECTs with mentor assigned" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_an_ineligible_ect_with_mentor
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      click_on "Not training"
      then_i_can_view_ineligible_participants

      when_i_click_on_the_participants_name "Ineligible With-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_ineligible_participant_status
    end
  end

  context "Ineligible ECTs without mentor assigned" do
    before { and_i_have_added_an_ineligible_ect_without_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_ineligible_participants

      when_i_click_on_the_participants_name "Ineligible Without-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_ineligible_participant_status
    end
  end

  context "Ineligible mentor" do
    before { and_i_have_added_an_ineligible_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_ineligible_participants

      when_i_click_on_the_participants_name "Ineligible mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_ineligible_participant_status
    end
  end

  context "Eligible ECTs with a mentor assigned" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_an_eligible_ect_with_mentor
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_fip_unpartnered_eligible_participants

      when_i_click_on_the_participants_name "Eligible With-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_eligible_fip_unpartnered_status
    end
  end

  context "Eligible ECTs without a mentor assigned" do
    before { and_i_have_added_an_eligible_ect_without_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_fip_unpartnered_eligible_participants

      when_i_click_on_the_participants_name "Eligible Without-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_eligible_fip_unpartnered_status
    end
  end

  context "Eligible mentor" do
    before { and_i_have_added_an_eligible_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_fip_unpartnered_eligible_participants

      when_i_click_on_the_participants_name "Eligible mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_eligible_fip_unpartnered_status
    end
  end

  context "Contacted for info ECTs with mentor assigned" do
    before do
      and_i_have_added_a_mentor
      and_i_have_added_a_contacted_for_info_ect_with_mentor
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_contacted_for_info_participants

      when_i_click_on_the_participants_name "CFI With-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_contacted_for_info_status
    end
  end

  context "Contacted for info ECTs without mentor assigned" do
    before { and_i_have_added_a_contacted_for_info_ect_without_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_contacted_for_info_participants

      when_i_click_on_the_participants_name "CFI Without-mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_contacted_for_info_bounced_email_status
    end
  end

  context "Contacted for info mentor" do
    before { and_i_have_added_a_contacted_for_info_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_contacted_for_info_participants

      when_i_click_on_the_participants_name "CFI Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_contacted_for_info_status
    end
  end

  context "Details being checked ECT with mentor" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_a_details_being_checked_ect_with_mentor
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_details_being_checked_participants

      when_i_click_on_the_participants_name "DBC With-Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_details_being_checked_status
    end
  end

  context "Details being checked ECT without mentor" do
    before { and_i_have_added_a_details_being_checked_ect_without_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_details_being_checked_participants

      when_i_click_on_the_participants_name "DBC Without-Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_details_being_checked_status
    end
  end

  context "Details being checked mentor" do
    before { and_i_have_added_a_details_being_checked_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_details_being_checked_participants

      when_i_click_on_the_participants_name "DBC Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_details_being_checked_mentor_status
    end
  end

  context "Details being checked ECT with mentor" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_a_no_qts_ect_with_mentor
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_no_qts_ects

      when_i_click_on_the_participants_name "No-qts With-Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_no_qts_status
    end
  end

  context "Details being checked ECT without mentor" do
    before { and_i_have_added_a_no_qts_ect_without_mentor }

    scenario "Induction coordinators can view and manage participant" do
      given_i_can_view_the_fip_induction_dashboard_without_partnership_details
      when_i_navigate_to_participants_dashboard
      then_i_can_view_no_qts_ects

      when_i_click_on_the_participants_name "No-qts Without-Mentor"
      then_i_am_taken_to_view_details_page
      then_i_can_view_no_qts_status
    end
  end
end
