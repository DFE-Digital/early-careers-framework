# frozen_string_literal: true

require "rails_helper"
require "./spec/features/scenarios/changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type} on CIP"
  str += " is to be onboarded to CIP"
  str
end

def when_context(scenario)
  str = "When they are onboarded by the new SIT"
  str += " before any declarations are made" if (scenario.new_declarations + scenario.prior_declarations).empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "CIP to CIP - Transfer a participant",
              with_feature_flags: { eligibility_notifications: "active" },
              type: :feature,
              end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "../changes_of_circumstances_fixtures.csv")

  %w[active inactive].each do |flag_state|
    context "when programme type changes for 2025 are #{flag_state}", with_feature_flags: { programme_type_changes_2025: flag_state } do
      CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
        next if includes.any? && !includes.include?(index + 2)

        scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

        next unless scenario.original_programme == "CIP" && scenario.new_programme == "CIP"

        let(:tokens) { {} }

        let!(:cohort) do
          cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
          allow(Cohort).to receive(:current).and_return(cohort)
          allow(Cohort).to receive(:next).and_return(cohort)
          allow(Cohort).to receive(:active_registration_cohort).and_return(cohort)
          allow(Cohort).to receive(:destination_from_frozen_cohort).and_return(cohort)
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
            given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

            travel_to(milestone_started.milestone_date - 2.months) do
              Importers::CreateCohort.new(path_to_csv: Rails.root.join("db/data/cohorts/cohorts.csv")).call
              Importers::CreateCallOffContract.new.call
              Importers::CreateStatement.new(path_to_csv: Rails.root.join("db/data/statements/statements.csv")).call
            end

            and_sit_at_pupil_premium_school_reported_programme "Original SIT", "CIP"

            and_sit_at_pupil_premium_school_reported_programme "New SIT", "CIP"

            and_sit_reported_participant "Original SIT",
                                         "The Participant",
                                         scenario.participant_trn,
                                         scenario.participant_dob,
                                         scenario.participant_email,
                                         scenario.participant_type
          end

          context when_context(scenario) do
            before do
              when_developers_transfer_the_active_participant "New SIT",
                                                              "The Participant"

              and_eligible_training_declarations_are_made_payable
            end

            include_examples "CIP to CIP", scenario
          end
        end
      end
    end
  end
end
