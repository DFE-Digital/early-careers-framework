# frozen_string_literal: true

require "rails_helper"
require_relative "../../features/schools/training_dashboard/manage_training_steps"

RSpec.shared_examples "manage fip participants example", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
  end

  context "Ineligible ECTs with mentor assigned" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_an_ineligible_ect_with_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "Ineligible With-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:not_allowed)
    end
  end

  context "Ineligible ECTs without mentor assigned" do
    before do
      and_i_have_added_an_ineligible_ect_without_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "Ineligible Without-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:not_allowed)
    end
  end

  context "Ineligible mentor" do
    before do
      and_i_have_added_an_ineligible_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_mentors_dashboard
      when_i_filter_by("Not mentoring (1)")
      when_i_click_on_the_participants_name "Ineligible mentor"
      then_i_am_taken_to_view_mentor_details_page
    end
  end

  context "ERO mentor" do
    before do
      and_i_have_added_an_ero_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_mentors_dashboard
      when_i_filter_by("Not mentoring (1)")
      when_i_click_on_the_participants_name "ero mentor"
      then_i_am_taken_to_view_mentor_details_page
    end
  end

  context "Eligible ECTs with a mentor assigned" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_an_eligible_ect_with_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "Eligible With-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:registered_for_fip_training)
      and_the_participant_is_displayed_mentored_by(@contacted_for_info_mentor.full_name)
    end
  end

  context "Eligible ECTs without a mentor assigned" do
    before do
      and_i_have_added_an_eligible_ect_without_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "Eligible Without-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:registered_for_fip_training)
    end
  end

  context "Eligible mentor" do
    before do
      and_i_have_added_an_eligible_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_mentors_dashboard
      when_i_filter_by("Not mentoring (1)")
      when_i_click_on_the_participants_name "Eligible mentor"
      then_i_am_taken_to_view_mentor_details_page
    end
  end

  context "Contacted for info ECTs with mentor assigned" do
    before do
      and_i_have_added_a_mentor
      and_i_have_added_a_contacted_for_info_ect_with_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "CFI With-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:request_for_details_delivered)
    end
  end

  context "Contacted for info ECTs without mentor assigned" do
    before do
      and_i_have_added_a_contacted_for_info_ect_without_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "CFI Without-mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:request_for_details_failed)
    end
  end

  context "Contacted for info mentor" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_mentors_dashboard
      when_i_filter_by("Not mentoring (1)")
      when_i_click_on_the_participants_name "CFI Mentor"
      then_i_am_taken_to_view_mentor_details_page
    end
  end

  context "Details being checked ECT with mentor" do
    before do
      and_i_have_added_a_contacted_for_info_mentor
      and_i_have_added_a_details_being_checked_ect_with_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "DBC With-Mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:different_trn)
    end
  end

  context "Details being checked ECT without mentor" do
    before do
      and_i_have_added_a_details_being_checked_ect_without_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_ect_dashboard
      when_i_click_on_the_participants_name "DBC Without-Mentor"
      then_i_am_taken_to_view_ect_details_page
      then_i_can_view_participant_with_status(:different_trn)
    end
  end

  context "Details being checked mentor" do
    before do
      and_i_have_added_a_details_being_checked_mentor
      and_i_am_signed_in_as_an_induction_coordinator
      and_i_click(Cohort.current.description)
    end

    scenario "Induction coordinators can view and manage participant" do
      given_i_am_taken_to_fip_induction_dashboard
      when_i_navigate_to_mentors_dashboard
      when_i_filter_by("Not mentoring (1)")
      when_i_click_on_the_participants_name "DBC Mentor"
      then_i_am_taken_to_view_mentor_details_page
    end
  end
end
