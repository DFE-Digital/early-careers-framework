# frozen_string_literal: true

require "rails_helper"
require "./db/legacy_seeds/call_off_contracts"
require "./spec/features/scenarios/changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type} on FIP"
  str += " is to be onboarded to FIP using a Different Provider"
  str
end

def when_context(scenario)
  str = "When they are onboarded by the new SIT"
  str += " before any declarations are made" if (scenario.new_declarations + scenario.prior_declarations).empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "FIP to FIP with different provider - Transfer a participant",
              with_feature_flags: {
                eligibility_notifications: "active",
                change_of_circumstances: "active",
              },
              type: :feature,
              end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "../changes_of_circumstances_fixtures.csv")
  CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
    next if includes.any? && !includes.include?(index + 2)

    scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

    next unless scenario.original_programme == "FIP" && scenario.new_programme == "FIP" && scenario.transfer == :different_provider

    let(:tokens) { {} }

    let!(:cohort) do
      cohort = create(:cohort, start_year: 2021)
      allow(Cohort).to receive(:current).and_return(cohort)
      allow(Cohort).to receive(:next).and_return(cohort)
      allow(Cohort).to receive(:active_registration_cohort).and_return(cohort)
      allow(cohort).to receive(:next).and_return(cohort)
      allow(cohort).to receive(:previous).and_return(cohort)
      cohort
    end
    let!(:schedule) do
      create(:ecf_schedule, name: "ECF September standard 2021", schedule_identifier: "ecf-standard-september", cohort:)
    end
    let!(:milestone_started) do
      create :milestone,
             schedule:,
             name: "Output 1 - Participant Start",
             start_date: Date.new(2021, 9, 1),
             milestone_date: Date.new(2021, 11, 30),
             payment_date: Date.new(2021, 11, 30),
             declaration_type: "started"
    end
    let!(:milestone_retained_1) do
      create :milestone,
             schedule:,
             name: "Output 2 - Retention Point 1",
             start_date: Date.new(2021, 11, 1),
             milestone_date: Date.new(2022, 1, 31),
             payment_date: Date.new(2022, 2, 28),
             declaration_type: "retained-1"
    end
    let!(:privacy_policy) do
      privacy_policy = create(:privacy_policy)
      PrivacyPolicy::Publish.call
      privacy_policy
    end

    context given_context(scenario) do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "New Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

        travel_to(milestone_started.milestone_date - 2.months) do
          Seeds::CallOffContracts.new.call
          Importers::SeedStatements.new.call
        end

        and_sit_at_pupil_premium_school_reported_programme "Original SIT", "FIP"
        and_lead_provider_reported_partnership "Original Lead Provider", "Original SIT"

        and_sit_at_pupil_premium_school_reported_programme "New SIT", "FIP"
        and_lead_provider_reported_partnership "New Lead Provider", "New SIT"

        and_sit_reported_participant "Original SIT",
                                     "The Participant",
                                     scenario.participant_trn,
                                     scenario.participant_dob,
                                     scenario.participant_email,
                                     scenario.participant_type
      end

      context when_context(scenario) do
        before do
          scenario.prior_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "Original Lead Provider",
                                                            scenario.participant_type,
                                                            "The Participant",
                                                            declaration_type
          end

          when_school_uses_the_transfer_participant_wizard "New SIT",
                                                           "The Participant",
                                                           scenario.participant_email,
                                                           scenario.participant_trn,
                                                           scenario.participant_dob,
                                                           same_provider: false

          scenario.new_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "New Lead Provider",
                                                            scenario.participant_type,
                                                            "The Participant",
                                                            declaration_type
          end

          and_eligible_training_declarations_are_made_payable
        end

        include_examples "FIP to FIP with different provider", scenario, "active"
      end
    end
  end
end
