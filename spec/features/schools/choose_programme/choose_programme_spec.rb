# frozen_string_literal: true

require "rails_helper"
require_relative "./choose_programme_steps"
require_relative "../training_dashboard/manage_training_steps"

RSpec.feature "Schools should be able to choose their programme", type: :feature, js: true, rutabaga: false do
  include ChooseProgrammeSteps

  before do
    FeatureFlag.activate(:multiple_cohorts)
  end

  after do
    reset_time
  end

  scenario "A school chooses no ECTs expected in next academic year" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
    and_the_next_cohort_is_open_for_registrations
    and_i_am_signed_in_as_an_induction_coordinator

    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
    and_the_page_should_be_accessible

    when_i_choose_no_ects
    and_i_click_continue
    then_i_am_taken_to_the_submitted_page
    and_i_see_the_school_name

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
    and_the_dashboard_page_shows_the_no_ects_message
  end

  scenario "A school chooses ECTs expected in next academic year and training DfE funded" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
    and_the_next_cohort_is_open_for_registrations
    and_i_am_signed_in_as_an_induction_coordinator

    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
    and_the_page_should_be_accessible

    when_i_choose_ects_expected
    and_i_click_continue
    then_i_am_taken_to_the_how_will_you_run_training_page

    when_i_choose_dfe_funded_training
    and_i_click_continue
    then_i_am_taken_to_the_training_confirmation_page

    when_i_click_the_confirm_button
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
    and_i_see_training_provider_to_be_confirmed
    and_i_see_delivery_partner_to_be_confirmed
    and_i_see_add_ects_link
  end

  scenario "A school chooses ECTs expected in next academic year and deliver own programme" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
    and_the_next_cohort_is_open_for_registrations
    and_i_am_signed_in_as_an_induction_coordinator

    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
    and_the_page_should_be_accessible

    when_i_choose_ects_expected
    and_i_click_continue
    then_i_am_taken_to_the_how_will_you_run_training_page

    when_i_choose_deliver_your_own_programme
    and_i_click_continue
    then_i_am_taken_to_the_training_confirmation_page

    when_i_click_the_confirm_button
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
  end

  scenario "A school chooses ECTs expected in next academic year and design and deliver own programme" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
    and_the_next_cohort_is_open_for_registrations
    and_i_am_signed_in_as_an_induction_coordinator

    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
    and_the_page_should_be_accessible

    when_i_choose_ects_expected
    and_i_click_continue
    then_i_am_taken_to_the_how_will_you_run_training_page

    when_i_choose_design_and_deliver_your_own_material
    and_i_click_continue
    then_i_am_taken_to_the_training_confirmation_page

    when_i_click_the_confirm_button
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
  end

  context "FIP" do
    scenario "A school chooses to keep the same FIP programme in the new cohort" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_the_next_cohort_is_open_for_registrations
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page
      and_i_see_the_current_lead_provider
      and_i_see_the_delivery_partner

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_the_current_lead_provider
      and_i_see_the_delivery_partner
    end

    context "Changing training" do
      scenario "A school chooses to use a different lead provider" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_the_next_cohort_is_open_for_registrations
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_current_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_leave_lead_provider
        and_i_click_continue

        then_i_am_taken_to_the_change_lead_provider_confirmation_page

        when_i_click_the_confirm_button
        then_a_notification_email_is_sent_to_the_lead_provider
        then_i_am_taken_to_the_training_change_submitted_page

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_training_provider_to_be_confirmed
        and_i_see_delivery_partner_to_be_confirmed
      end

      scenario "A school chooses to change delivery partner" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_the_next_cohort_is_open_for_registrations
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_current_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_change_delivery_partner
        and_i_click_continue
        then_i_am_taken_to_the_change_delivery_partner_confirmation_page

        when_i_click_the_confirm_button
        then_a_notification_email_is_sent_to_the_lead_provider
        then_i_am_taken_to_the_training_change_submitted_page

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_training_provider_to_be_confirmed
        and_i_see_delivery_partner_to_be_confirmed
      end

      scenario "A school chooses to deliver own programme" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_the_next_cohort_is_open_for_registrations
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_current_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_deliver_own_programme
        and_i_click_continue
        then_i_am_taken_to_the_change_to_design_own_programme_confirmation_page

        when_i_click_the_confirm_button
        then_a_notification_email_is_sent_to_the_lead_provider
        then_i_am_taken_to_the_training_change_submitted_page

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_programme_to_dfe_accredited_materials
      end

      scenario "A school chooses to design and deliver own programme" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_the_next_cohort_is_open_for_registrations
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_current_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_design_and_deliver_own_programme
        and_i_click_continue
        then_i_am_taken_to_the_change_to_design_and_deliver_own_programme_confirmation_page

        when_i_click_the_confirm_button
        then_a_notification_email_is_sent_to_the_lead_provider
        then_i_am_taken_to_the_training_change_submitted_page

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_programme_to_design_and_deliver_own_programme
      end
    end
  end
end
