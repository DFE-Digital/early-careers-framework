# frozen_string_literal: true

require "rails_helper"
require "./db/seeds/call_off_contracts"
require "./spec/features/scenarios/changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type} on FIP"
  str += " is to be onboarded to CIP"
  str
end

def when_context(scenario)
  str = "When they are onboarded by the new SIT"
  str += " before any declarations are made" if scenario.all_declarations.empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "FIP to CIP - Transfer a participant", type: :feature, end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "../changes_of_circumstances_fixtures.csv")
  CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
    next if includes.any? && !includes.include?(index + 2)

    scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

    next unless scenario.original_programme == "FIP" && scenario.new_programme == "CIP"

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
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

        Seeds::CallOffContracts.new.call
        Importers::SeedStatements.new.call

        and_sit_at_pupil_premium_school_reported_programme "Original SIT", "FIP"
        and_lead_provider_reported_partnership "Original Lead Provider", "Original SIT"

        and_sit_at_pupil_premium_school_reported_programme "New SIT", "CIP"

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

          when_developers_transfer_the_active_participant "New SIT",
                                                          "the Participant"

          and_eligible_training_declarations_are_made_payable

          and_lead_provider_statements_have_been_created "Original Lead Provider"
          and_lead_provider_statements_have_been_created "Another Lead Provider"
        end

        include_examples "FIP to CIP", scenario
      end
    end
  end
end
