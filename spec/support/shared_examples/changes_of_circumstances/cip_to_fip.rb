# frozen_string_literal: true

require "rails_helper"
require "./db/seeds/call_off_contracts"
require "./spec/features/scenarios/changes_of_circumstance_scenario"

RSpec.shared_examples "CIP to FIP" do |scenario|
  context "Then the Original SIT" do
    subject(:original_sit) { "Original SIT" }

    it Steps::ChangesOfCircumstanceSteps.then_sit_context(scenario, is_hidden: true),
       :aggregate_failures do
      given_i_authenticate_as_the_user_with_the_full_name "Original SIT"
      and_i_am_on_the_school_dashboard_page
      then_school_dashboard_page_does_not_have_participants

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

  context "Then the New Lead Provider" do
    subject(:new_lead_provider) { "New Lead Provider" }

    it Steps::ChangesOfCircumstanceSteps.then_lead_provider_context(scenario, scenario.all_declarations),
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

      scenario.duplicate_declarations.each do |declaration_type|
        is_expected.to_not make_duplicate_training_declaration "the Participant",
                                                               scenario.participant_type,
                                                               declaration_type
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
                                                                   scenario.all_declarations

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
