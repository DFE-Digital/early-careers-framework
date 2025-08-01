# frozen_string_literal: true

require "rails_helper"
require_relative "./choose_programme_steps"

RSpec.feature "Schools should be able to choose their programme", type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2022, 6, 5, 16, 15, 0) do
  include ChooseProgrammeSteps

  %w[active inactive].each do |flag_state|
    context "when programme type changes for 2025 are #{flag_state}", with_feature_flags: { programme_type_changes_2025: flag_state } do
      scenario "A school chooses no ECTs expected in next academic year" do
        given_a_school_with_no_chosen_programme_for_next_academic_year
        and_i_am_signed_in_as_an_induction_coordinator

        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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

        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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
      end

      scenario "A CIP-only non-previously_fip school chooses ECTs expected in next academic year and training school funded" do
        given_a_school_with_no_chosen_programme_for_next_academic_year(cip_only: true)
        and_i_am_signed_in_as_an_induction_coordinator

        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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

      scenario "A CIP-Only previously_fip school chooses ECTs expected in next academic year and training school funded" do
        given_a_school_with_no_chosen_programme_for_next_academic_year(cip_only: true, previously_fip: true)
        and_i_am_signed_in_as_an_induction_coordinator

        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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
        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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

        and_i_see_the_choose_training_material_content unless FeatureFlag.active?(:programme_type_changes_2025)
      end

      scenario "A school chooses ECTs expected in next academic year and design and deliver own programme" do
        given_a_school_with_no_chosen_programme_for_next_academic_year
        and_i_am_signed_in_as_an_induction_coordinator

        then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
        and_the_page_should_be_accessible

        when_i_click_continue
        then_i_am_taken_to_ects_expected_in_next_academic_year_page

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
          then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
          and_the_page_should_be_accessible

          when_i_click_continue
          then_i_am_taken_to_ects_expected_in_next_academic_year_page

          when_i_choose_ects_expected
          and_i_click_continue
          then_i_am_taken_to_what_changes_page
        end

        scenario "A school chooses to keep the same FIP programme in the new cohort" do
          given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
          and_cohort_for_next_academic_year_is_created
          and_a_provider_relationship_exists_for_the_lp_and_dp
          and_i_am_signed_in_as_an_induction_coordinator
          then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
          and_the_page_should_be_accessible

          when_i_click_continue
          then_i_am_taken_to_ects_expected_in_next_academic_year_page

          when_i_choose_ects_expected
          and_i_click_continue
          then_i_am_taken_to_the_keep_providers_page
          and_i_see_the_lead_provider
          and_i_see_the_delivery_partner

          and_i_choose_yes
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
          then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
          and_the_page_should_be_accessible

          when_i_click_continue
          then_i_am_taken_to_ects_expected_in_next_academic_year_page

          when_i_choose_ects_expected
          and_i_click_continue
          then_i_am_taken_to_the_keep_providers_page
          and_i_see_the_lead_provider
          and_i_see_the_delivery_partner

          when_i_choose_yes
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
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_keep_providers_page
            and_i_see_the_lead_provider
            and_i_see_the_delivery_partner

            when_i_choose_no
            and_i_click_continue
            then_i_am_taken_to_what_changes_page

            when_i_choose_to_form_a_new_partnership
            and_i_click_continue
            then_i_am_taken_to_the_form_a_new_partnership_confirmation_page

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

          scenario "A school chooses to deliver own programme" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_keep_providers_page
            and_i_see_the_lead_provider
            and_i_see_the_delivery_partner

            when_i_choose_no
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
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_keep_providers_page
            and_i_see_the_lead_provider
            and_i_see_the_delivery_partner

            when_i_choose_no
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
          then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
          and_the_page_should_be_accessible

          when_i_click_continue
          then_i_am_taken_to_ects_expected_in_next_academic_year_page

          when_i_choose_ects_expected
          and_i_click_continue
          then_i_am_taken_to_the_keep_providers_page

          when_i_choose_yes
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

        context "When is a British school overseas (GIAS 37)" do
          before do
            create(:appropriate_body_national_organisation, name: "Educational Success Partners (ESP)")
          end

          scenario "A school chooses to appoint an appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(37)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Teaching school hub"
            when_i_fill_appropriate_body_with @teaching_school_hubs.first.name
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body @teaching_school_hubs.first.name
          end

          scenario "A school chooses the default appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(37)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Educational Success Partners (ESP)"
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body "Educational Success Partners (ESP)"
          end

          scenario "The appropriate body is not listed" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(37)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            when_i_click_on_appropriate_body_not_listed
            then_i_am_taken_to_the_complete_page
            and_i_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_no_appropriate_body
          end
        end

        context "When is an independent school (GIAS 10)" do
          before do
            create(:appropriate_body_national_organisation, name: "Independent Schools Teacher Induction Panel (IStip)")
          end

          scenario "A school chooses to appoint an appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(10)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Teaching school hub"
            when_i_fill_appropriate_body_with @teaching_school_hubs.first.name
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body @teaching_school_hubs.first.name
          end

          scenario "A school chooses the default appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(10)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Independent Schools Teacher Induction Panel (IStip)"
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body "Independent Schools Teacher Induction Panel (IStip)"
          end
        end

        context "When is an independent school (GIAS 11)" do
          before do
            create(:appropriate_body_national_organisation, name: "Independent Schools Teacher Induction Panel (IStip)")
          end

          scenario "A school chooses to appoint an appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(11)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Teaching school hub"
            when_i_fill_appropriate_body_with @teaching_school_hubs.first.name
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body @teaching_school_hubs.first.name
          end

          scenario "A school chooses the default appropriate body" do
            given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
            and_school_type_is(11)
            and_cohort_for_next_academic_year_is_created
            and_a_provider_relationship_exists_for_the_lp_and_dp
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
            and_the_page_should_be_accessible

            when_i_click_continue
            then_i_am_taken_to_ects_expected_in_next_academic_year_page

            when_i_choose_ects_expected
            and_i_click_continue
            then_i_am_taken_to_the_how_will_you_run_training_page

            when_i_choose_deliver_your_own_programme
            and_i_click_continue
            then_i_am_taken_to_the_training_confirmation_page

            when_i_click_the_confirm_button
            then_i_am_taken_to_the_appropriate_body_appointed_page

            when_i_choose_yes
            and_i_click_continue
            then_i_am_taken_to_the_appropriate_body_type_page

            choose "Independent Schools Teacher Induction Panel (IStip)"
            and_i_click_continue
            then_i_am_taken_to_the_complete_page
            and_i_dont_see_the_tell_us_appropriate_body_copy

            when_i_click_on_the_return_to_your_training_link
            then_i_am_taken_to_the_manage_your_training_page
            and_i_see_appropriate_body "Independent Schools Teacher Induction Panel (IStip)"
          end
        end

        scenario "A school chooses to appoint a teaching school hub as appropriate body" do
          given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
          and_cohort_for_next_academic_year_is_created
          and_a_provider_relationship_exists_for_the_lp_and_dp
          and_i_am_signed_in_as_an_induction_coordinator
          then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
          and_the_page_should_be_accessible

          when_i_click_continue
          then_i_am_taken_to_ects_expected_in_next_academic_year_page

          when_i_choose_ects_expected
          and_i_click_continue
          then_i_am_taken_to_the_keep_providers_page

          when_i_choose_yes
          and_i_click_continue
          then_i_am_taken_to_the_appropriate_body_appointed_page

          when_i_choose_yes
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
  end

private

  def and_school_type_is(code)
    @school.update!(school_type_code: code)
  end

  def when_i_fill_appropriate_body_with(name)
    when_i_fill_in_autocomplete "schools-cohorts-setup-wizard-appropriate-body-id-field", with: name
  end

  def when_i_click_on_appropriate_body_not_listed
    click_on "My appropriate body isn't listed"
  end
end
