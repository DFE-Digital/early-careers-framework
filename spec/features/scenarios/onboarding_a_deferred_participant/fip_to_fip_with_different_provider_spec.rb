# frozen_string_literal: true

require "rails_helper"
require "./db/seeds/call_off_contracts"
require "./spec/features/scenarios/changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type} on FIP"
  str += " is to be onboarded to FIP using a Different Provider"
  str
end

def when_context(scenario)
  str = "When they are onboarded by the new SIT"
  str += " after being deferred"
  str += " before any declarations are made" if (scenario.new_declarations + scenario.prior_declarations).empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "FIP to FIP with different provider - Onboard a deferred participant", type: :feature, end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "../changes_of_circumstances_fixtures.csv")
  CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
    next if includes.any? && !includes.include?(index + 2)

    scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

    next unless scenario.original_programme == "FIP" && scenario.new_programme == "FIP" && scenario.transfer == :different_provider

    let(:cohort) { create :cohort, :current }

    let(:tokens) { {} }

    before do
      # given_a_cohort_with_start_year 2021
      given_a_privacy_policy_has_been_published

      and_feature_flag_is_active :eligibility_notifications
      and_feature_flag_is_active :change_of_circumstances

      # given_schedules_have_been_seeded

      create :ecf_schedule
    end

    context given_context(scenario) do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "New Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

        Seeds::CallOffContracts.new.call
        Importers::SeedStatements.new.call

        and_sit_at_pupil_premium_school_reported_programme "Original SIT", "FIP"
        and_lead_provider_reported_partnership "Original Lead Provider", "Original SIT"

        and_sit_at_pupil_premium_school_reported_programme "New SIT", "FIP"
        and_lead_provider_reported_partnership "New Lead Provider", "New SIT"

        and_sit_reported_participant "Original SIT",
                                     "the Participant",
                                     scenario.participant_email,
                                     scenario.participant_type
        and_participant_has_completed_registration "the Participant",
                                                   scenario.participant_trn,
                                                   scenario.participant_dob,
                                                   scenario.participant_type
      end

      context when_context(scenario) do
        before do
          scenario.prior_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "Original Lead Provider",
                                                            scenario.participant_type,
                                                            "the Participant",
                                                            declaration_type
          end

          when_developers_transfer_the_deferred_participant "New SIT",
                                                            "the Participant"

          scenario.new_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "New Lead Provider",
                                                            scenario.participant_type,
                                                            "the Participant",
                                                            declaration_type
          end

          and_eligible_training_declarations_are_made_payable

          and_lead_provider_statements_have_been_created "Original Lead Provider"
          and_lead_provider_statements_have_been_created "New Lead Provider"
          and_lead_provider_statements_have_been_created "Another Lead Provider"
        end

        context "Then the Original SIT" do
          subject(:original_sit) { "Original SIT" }

          it Steps::ChangesOfCircumstanceSteps.then_sit_context(scenario),
             :aggregate_failures do
            given_i_authenticate_as_the_user_with_the_full_name "Original SIT"
            and_i_am_on_the_school_dashboard_page

            when_i_view_participant_dashboard_from_school_dashboard_page
            and_i_view_not_training_from_school_participants_dashboard_page "the Participant"

            then_school_participant_details_page_shows_participant_details "the Participant",
                                                                           scenario.participant_email,
                                                                           "Eligible to start"

            sign_out
          end
        end

        context "Then the New SIT" do
          subject(:new_sit) { "New SIT" }

          it Steps::ChangesOfCircumstanceSteps.then_sit_context(scenario),
             :aggregate_failures do
            given_i_authenticate_as_the_user_with_the_full_name "New SIT"
            and_i_am_on_the_school_dashboard_page

            when_i_view_participant_dashboard_from_school_dashboard_page
            if scenario.participant_type == "ECT"
              and_i_view_ects_from_school_participants_dashboard_page "the Participant"
            else
              and_i_view_mentors_from_school_participants_dashboard_page "the Participant"
            end

            then_school_participant_details_page_shows_participant_details "the Participant",
                                                                           scenario.participant_email,
                                                                           "Eligible to start"

            sign_out
          end

          # what are the onward actions available to the new school - can they do them ??
        end

        context "Then the Original Lead Provider" do
          subject(:original_lead_provider) { "Original Lead Provider" }

          it Steps::ChangesOfCircumstanceSteps.then_lead_provider_context(scenario, scenario.see_new_declarations),
             :aggregate_failures do
            then_ecf_participants_api_has_participant_details "Original Lead Provider",
                                                              "the Participant",
                                                              scenario.participant_email,
                                                              scenario.participant_trn,
                                                              scenario.participant_type,
                                                              "Original SIT's School",
                                                              "active",
                                                              "active"

            then_participant_declarations_api_has_declarations "Original Lead Provider",
                                                               "the Participant",
                                                               scenario.see_original_declarations
          end

          # previous lead provider can void ??
        end

        context "Then the New Lead Provider" do
          subject(:new_lead_provider) { "New Lead Provider" }

          it Steps::ChangesOfCircumstanceSteps.then_lead_provider_context(scenario, scenario.see_new_declarations),
             :aggregate_failures do
            then_ecf_participants_api_has_participant_details "New Lead Provider",
                                                              "the Participant",
                                                              scenario.participant_email,
                                                              scenario.participant_trn,
                                                              scenario.participant_type,
                                                              "New SIT's School",
                                                              "active",
                                                              "active"

            then_participant_declarations_api_has_declarations "New Lead Provider",
                                                               "the Participant",
                                                               scenario.all_declarations

            if scenario.duplicate_declarations.any?
              scenario.duplicate_declarations.each do |declaration_type|
                is_expected.to_not make_duplicate_training_declaration "the Participant",
                                                                       scenario.participant_type,
                                                                       declaration_type
              end
            end
          end
        end

        context "Then other Lead Providers" do
          subject(:another_lead_provider) { "Another Lead Provider" }

          it Steps::ChangesOfCircumstanceSteps.then_lead_provider_context(scenario, is_hidden: true),
             :aggregate_failures do
            then_ecf_participants_api_does_not_have_participant_details "Another Lead Provider",
                                                                        "the Participant"

            then_participant_declarations_api_does_not_have_declarations "Another Lead Provider",
                                                                         "the Participant"
          end
        end

        context "Then the Support for Early Career Teachers Service" do
          subject(:support_ects) { "Support for Early Career Teachers Service" }

          it Steps::ChangesOfCircumstanceSteps.then_support_service_context(scenario),
             :aggregate_failures do
            then_ecf_users_endpoint_shows_the_current_record "the Participant",
                                                             scenario.participant_email,
                                                             scenario.participant_type,
                                                             "FIP"
          end
        end

        context "Then a Teacher CPD Finance User" do
          subject(:finance_user) { "Teacher CPD Finance User" }

          it Steps::ChangesOfCircumstanceSteps.then_finance_user_context(scenario),
             :aggregate_failures do
            given_i_authenticate_as_a_finance_user

            and_i_am_on_the_finance_portal
            and_i_view_participant_drilldown_from_finance_portal

            when_i_find_from_finance_participant_drilldown_search "the Participant"

            then_the_finance_portal_shows_the_current_participant_record "the Participant",
                                                                         scenario.participant_type,
                                                                         "New SIT",
                                                                         "New Lead Provider",
                                                                         "active",
                                                                         "active",
                                                                         scenario.see_new_declarations

            when_i_am_on_the_finance_portal
            and_i_view_payment_breakdown_from_finance_portal
            and_i_complete_from_finance_payment_breakdown_report_wizard "Original Lead Provider"

            then_the_finance_portal_shows_the_lead_provider_payment_breakdown "Original Lead Provider",
                                                                              scenario.original_payment_ects,
                                                                              scenario.original_payment_mentors,
                                                                              scenario.original_started_declarations,
                                                                              scenario.original_retained_declarations,
                                                                              0, 0

            when_i_am_on_the_finance_portal
            and_i_view_payment_breakdown_from_finance_portal
            and_i_complete_from_finance_payment_breakdown_report_wizard "New Lead Provider"

            then_the_finance_portal_shows_the_lead_provider_payment_breakdown "New Lead Provider",
                                                                              scenario.new_payment_ects,
                                                                              scenario.new_payment_mentors,
                                                                              scenario.new_started_declarations,
                                                                              scenario.new_retained_declarations,
                                                                              0, 0

            when_i_am_on_the_finance_portal
            and_i_view_payment_breakdown_from_finance_portal
            and_i_complete_from_finance_payment_breakdown_report_wizard "Another Lead Provider"

            then_the_finance_portal_shows_the_lead_provider_payment_breakdown "Another Lead Provider",
                                                                              0, 0, 0, 0, 0, 0

            sign_out
          end
        end

        context "Then a Teacher CPD Admin User" do
          subject(:admin_user) { "Teacher CPD Admin User" }

          it Steps::ChangesOfCircumstanceSteps.then_admin_user_context(scenario),
             :aggregate_failures do
            given_i_authenticate_as_an_admin

            and_i_am_on_the_admin_support_portal
            and_i_view_participant_list_from_admin_support_portal
            and_i_view_participant_from_admin_support_participant_list "the Participant"

            then_the_admin_portal_shows_the_current_participant_record "the Participant",
                                                                       "New SIT",
                                                                       "New Lead Provider",
                                                                       "Eligible to start"

            sign_out
          end
        end

        context "Then the Analytics Dashboards" do
          subject(:analytics_user) { "Analysts" }

          it "is expected to report the correct participant details for \"the Participant\"",
             :aggregate_failures,
             skip: "Not yet implemented" do
            expect(subject).to report_correct_participant_details "the Participant"
          end
        end
      end
    end
  end
end
