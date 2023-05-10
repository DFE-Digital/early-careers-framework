# frozen_string_literal: true

require "rails_helper"
require_relative "./choose_programme_steps"

RSpec.feature "Schools should be able to choose their programme", type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2022, 6, 5, 16, 15, 0) do
  include ChooseProgrammeSteps

  scenario "A school chooses no ECTs expected in next academic year" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
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
    then_i_am_taken_to_the_appropriate_body_appointed_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
    and_i_see_training_provider_to_be_confirmed
    and_i_see_delivery_partner_to_be_confirmed
    and_i_see_add_ects_link
  end

  scenario "A CIT-only school chooses ECTs expected in next academic year and training school funded" do
    given_a_school_with_no_chosen_programme_for_next_academic_year(cip_only: true)
    and_i_am_signed_in_as_an_induction_coordinator

    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
    and_the_page_should_be_accessible

    when_i_choose_ects_expected
    and_i_click_continue
    then_i_am_taken_to_the_how_will_you_run_training_page

    when_i_choose_use_a_training_provider_funded_by_your_school
    and_i_click_continue
    then_i_am_taken_to_the_training_confirmation_page

    when_i_click_the_confirm_button
    then_i_am_taken_to_the_appropriate_body_appointed_page

    when_i_choose_no
    and_i_click_continue

    then_i_am_on_the_school_funded_fip_training_submitted_page
    and_the_page_should_be_accessible
    and_i_can_get_guidance_about_an_arrangement_with_a_training_provider_on_the_school_funded_fip_training_submitted_page
    and_i_can_email_cpd_for_help_on_the_school_funded_fip_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
  end

  scenario "A school chooses ECTs expected in next academic year and deliver own programme" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
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
    then_i_am_taken_to_the_appropriate_body_appointed_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
    and_i_see_the_choose_training_material_content
  end

  scenario "A school chooses ECTs expected in next academic year and design and deliver own programme" do
    given_a_school_with_no_chosen_programme_for_next_academic_year
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
    then_i_am_taken_to_the_appropriate_body_appointed_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_taken_to_the_training_submitted_page

    when_i_click_on_the_return_to_your_training_link
    then_i_am_taken_to_the_manage_your_training_page
  end

  context "FIP" do
    scenario "A school with challenged partnership chooses expects ects" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_but_partnership_was_challenged
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_how_will_you_run_training_page
    end

    scenario "A school chooses to keep the same FIP programme in the new cohort" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page
      and_i_see_the_lead_provider
      and_i_see_the_delivery_partner

      and_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page

      when_i_go_back_to_change_provider_page
      and_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_the_lead_provider
      and_i_see_the_delivery_partner
      and_i_see_the_challenge_link
    end

    scenario "Empty LP and DP names for challenged partnerships" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page
      and_i_see_the_lead_provider
      and_i_see_the_delivery_partner

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page

      when_i_challenge_the_new_cohort_partnership
      and_i_visit_the_school_manage_training
      then_i_see_black_lp_and_dp_names
      and_i_do_not_see_the_challenge_link
    end

    context "Changing training" do
      scenario "A school chooses to use a different lead provider" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_a_provider_relationship_exists_for_the_lp_and_dp
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_leave_lead_provider
        and_i_click_continue

        then_i_am_taken_to_the_change_lead_provider_confirmation_page

        when_i_click_the_confirm_button
        then_i_am_taken_to_the_appropriate_body_appointed_page

        when_i_choose_no
        and_i_click_continue
        then_i_am_taken_to_the_training_change_submitted_page
        and_i_see_the_lead_provider
        and_i_see_the_delivery_partner
        and_a_notification_email_is_sent_to_the_lead_provider

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_training_provider_to_be_confirmed
        and_i_see_delivery_partner_to_be_confirmed
      end

      scenario "A school chooses to change delivery partner" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_a_provider_relationship_exists_for_the_lp_and_dp
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_change_delivery_partner
        and_i_click_continue
        then_i_am_taken_to_the_change_delivery_partner_confirmation_page

        when_i_click_the_confirm_button
        then_i_am_taken_to_the_appropriate_body_appointed_page

        when_i_choose_no
        and_i_click_continue
        then_i_am_taken_to_the_training_change_submitted_page
        and_i_see_the_delivery_partner
        and_a_notification_email_is_sent_to_the_lead_provider

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_training_partner_to_be_the_previous_one
        and_i_see_delivery_partner_to_be_confirmed
      end

      scenario "A school chooses to deliver own programme" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_a_provider_relationship_exists_for_the_lp_and_dp
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_deliver_own_programme
        and_i_click_continue
        then_i_am_taken_to_the_change_to_design_own_programme_confirmation_page

        when_i_click_the_confirm_button
        then_i_am_taken_to_the_appropriate_body_appointed_page

        when_i_choose_no
        and_i_click_continue
        then_i_am_taken_to_the_training_change_submitted_page
        and_a_notification_email_is_sent_to_the_lead_provider

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_programme_to_dfe_accredited_materials
      end

      scenario "A school chooses to design and deliver own programme" do
        given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
        and_cohort_for_next_academic_year_is_created
        and_a_provider_relationship_exists_for_the_lp_and_dp
        and_i_am_signed_in_as_an_induction_coordinator
        when_i_start_programme_selection_for_next_cohort
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

        when_i_choose_ects_expected
        and_i_click_continue
        then_i_am_taken_to_the_change_provider_page
        and_i_see_the_lead_provider
        and_i_see_the_delivery_partner

        when_i_choose_yes
        and_i_click_continue
        then_i_am_taken_to_what_changes_page

        when_i_choose_to_design_and_deliver_own_programme
        and_i_click_continue
        then_i_am_taken_to_the_change_to_design_and_deliver_own_programme_confirmation_page

        when_i_click_the_confirm_button
        then_i_am_taken_to_the_appropriate_body_appointed_page

        when_i_choose_no
        and_i_click_continue
        then_i_am_taken_to_the_training_change_submitted_page
        and_a_notification_email_is_sent_to_the_lead_provider

        when_i_click_on_the_return_to_your_training_link
        then_i_am_taken_to_the_manage_your_training_page
        and_i_see_programme_to_design_and_deliver_own_programme
      end
    end
  end

  context "Appropriate body" do
    before do
      @local_authorities = create_list(:appropriate_body_local_authority, 5)
      @teaching_school_hubs = create_list(:appropriate_body_teaching_school_hub, 5)
      @national_organisations = create_list(:appropriate_body_national_organisation, 2)
    end

    scenario "A school does not appoint an appropriate body" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page
      and_i_see_the_tell_us_appropriate_body_copy

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_no_appropriate_body
    end

    scenario "A school chooses to appoint a local authority as appropriate body" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_yes
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_type_page

      when_i_choose_local_authority
      and_i_click_continue
      then_i_am_taken_to_the_local_authorities_selection_page

      when_i_fill_appropriate_body_with @local_authorities.first.name
      and_i_click_continue
      then_i_am_taken_to_the_complete_page
      and_i_dont_see_the_tell_us_appropriate_body_copy

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_appropriate_body @local_authorities.first.name
    end

    scenario "A school chooses to appoint a national organisation as appropriate body" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_yes
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_type_page

      when_i_choose_national_organisation
      and_i_click_continue
      then_i_am_taken_to_the_select_national_organisation_selection_page

      choose @national_organisations.first.name
      and_i_click_continue
      then_i_am_taken_to_the_complete_page
      and_i_dont_see_the_tell_us_appropriate_body_copy

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_appropriate_body @national_organisations.first.name
    end

    scenario "A school chooses to appoint a teaching school hub as appropriate body" do
      given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
      and_cohort_for_next_academic_year_is_created
      and_a_provider_relationship_exists_for_the_lp_and_dp
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_start_programme_selection_for_next_cohort
      then_i_am_taken_to_ects_expected_in_next_academic_year_page

      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_change_provider_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_yes
      and_i_click_continue
      then_i_am_taken_to_the_appropriate_body_type_page

      when_i_choose_teaching_school_hub
      and_i_click_continue
      then_i_am_taken_to_the_teaching_school_hubs_selection_page

      when_i_fill_appropriate_body_with @teaching_school_hubs.first.name
      and_i_click_continue
      then_i_am_taken_to_the_complete_page
      and_i_dont_see_the_tell_us_appropriate_body_copy

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_appropriate_body @teaching_school_hubs.first.name
    end
  end
end
