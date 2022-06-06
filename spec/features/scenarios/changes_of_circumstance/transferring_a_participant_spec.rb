# frozen_string_literal: true

require "rails_helper"
require "./db/seeds/call_off_contracts"
require_relative "./changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type}"
  str += " on #{scenario.original_programme} is to be transferred to #{scenario.new_programme}"
  str += " using the Same Provider" if scenario.transfer == :same_provider
  str += " using a Different Provider" if scenario.transfer == :different_provider
  str
end

def when_context(scenario)
  str = "When they are transferred by the new SIT"

  str += " before any declarations are made" if (scenario.new_declarations + scenario.prior_declarations).empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "Transfer a participant",
              with_feature_flags: {
                eligibility_notifications: "active",
                change_of_circumstances: "active",
              },
              type: :feature,
              end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "./transferring_a_participant_fixtures.csv")
  CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
    next if includes.any? && !includes.include?(index + 2)

    scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

    # scenarios that must be skipped as they will not be possible
    next if scenario.withdrawn_by == :lead_provider && scenario.new_declarations.any?

    let!(:cohort) do
      cohort = create(:cohort, start_year: 2021)
      allow(Cohort).to receive(:current).and_return(cohort)
      allow(Cohort).to receive(:next).and_return(cohort)
      cohort
    end
    let!(:schedule) do
      schedule = create(:ecf_schedule, name: "ECF September standard 2021", schedule_identifier: "ecf-standard-september", cohort:)
      create :milestone,
             schedule: schedule,
             name: "Output 1 - Participant Start",
             start_date: Date.new(2021, 9, 1),
             milestone_date: Date.new(2021, 11, 30),
             payment_date: Date.new(2021, 11, 30),
             declaration_type: "started"
      create :milestone,
             schedule: schedule,
             name: "Output 2 - Retention Point 1",
             start_date: Date.new(2021, 11, 1),
             milestone_date: Date.new(2022, 1, 31),
             payment_date: Date.new(2022, 2, 28),
             declaration_type: "retained-1"
      schedule
    end
    let!(:privacy_policy) do
      privacy_policy = create(:privacy_policy)
      PrivacyPolicy::Publish.call
      privacy_policy
    end

    let(:tokens) { {} }

    context given_context(scenario) do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "New Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

        Seeds::CallOffContracts.new.call
        Importers::SeedStatements.new.call

        if scenario.original_programme == "FIP"
          and_sit_at_pupil_premium_school_reported_programme "Original SIT", "FIP"
          and_lead_provider_reported_partnership "Original Lead Provider", "Original SIT"
        else
          and_sit_at_pupil_premium_school_reported_programme "Original SIT", "CIP"
        end

        if scenario.new_programme == "FIP"
          and_sit_at_pupil_premium_school_reported_programme "New SIT", "FIP"
          and_lead_provider_reported_partnership scenario.new_lead_provider_name, "New SIT"
        else
          and_sit_at_pupil_premium_school_reported_programme "New SIT", "CIP"
        end

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
            and_lead_provider_has_made_training_declaration "Original Lead Provider", scenario.participant_type, "the Participant", declaration_type
          end

          if scenario.original_programme == "FIP" && scenario.new_programme == "FIP"
            when_school_uses_the_transfer_participant_wizard "New SIT",
                                                             "the Participant",
                                                             scenario.participant_email,
                                                             scenario.participant_trn,
                                                             scenario.participant_dob,
                                                             same_provider: scenario.transfer == :same_provider
          else
            when_developers_transfer_the_active_participant "New SIT",
                                                            "the Participant"
          end

          scenario.new_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration scenario.new_lead_provider_name, scenario.participant_type, "the Participant", declaration_type
          end

          and_eligible_training_declarations_are_made_payable "January 2022"
        end

        context "Then the Original SIT" do
          subject(:original_sit) { "Original SIT" }

          if scenario.original_programme == "FIP" && scenario.new_programme == "FIP"
            it "can see the participant in the school portal" do
              then_sit_can_see_participant_in_school_portal original_sit, scenario
            end
          else
            it "cannot see the participant in the school portal" do
              then_sit_cannot_see_participant_in_school_portal original_sit
            end
          end
        end

        context "Then the New SIT" do
          subject(:new_sit) { "New SIT" }

          it "can see the participant in the school portal" do
            then_sit_can_see_participant_in_school_portal new_sit, scenario
          end

          # what are the onward actions available to the new school - can they do them ??
        end

        if scenario.original_programme == "FIP"
          context "Then the Original Lead Provider" do
            subject(:original_lead_provider) { "Original Lead Provider" }

            case scenario.see_original_details
            when :ALL
              it {
                is_expected.to find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                     scenario.participant_email,
                                                                                     scenario.participant_trn,
                                                                                     "New SIT's School",
                                                                                     scenario.participant_type,
                                                                                     scenario.prior_participant_status,
                                                                                     scenario.prior_training_status
              }
            when :OBFUSCATED
              it "is expected to be able to retrieve the obfuscated participant details for \"the Participant\" from the ecf participants endpoint", skip: "Not yet implemented" do
                is_expected.to find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                     nil,
                                                                                     scenario.participant_trn,
                                                                                     "New SIT's School",
                                                                                     scenario.participant_type
              end
            else
              it {
                is_expected.to_not find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                         scenario.participant_email,
                                                                                         scenario.participant_trn,
                                                                                         "New SIT's School",
                                                                                         scenario.participant_type
              }
            end

            if scenario.see_original_declarations.any?
              it { is_expected.to find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.see_original_declarations }
            elsif scenario.all_declarations.any?
              it { is_expected.to_not find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.all_declarations }
            end

            # previous lead provider can void ??
          end
        end

        if scenario.new_programme == "FIP" && scenario.transfer == :different_provider
          context "Then the New Lead Provider" do
            subject(:new_lead_provider) { "New Lead Provider" }

            case scenario.see_new_details
            when :ALL
              it {
                is_expected.to find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                     scenario.participant_email,
                                                                                     scenario.participant_trn,
                                                                                     "New SIT's School",
                                                                                     scenario.participant_type,
                                                                                     scenario.new_participant_status,
                                                                                     scenario.new_training_status
              }
            when :not_applicable
              # not applicable
            else
              raise "scenario.see_new_details is not a valid value"
            end

            if scenario.duplicate_declarations.any?
              it "should not be able to make duplicate declarations", :aggregate_failures do
                scenario.duplicate_declarations.each do |declaration_type|
                  expect(subject).to_not make_duplicate_training_declaration "the Participant", scenario.participant_type, declaration_type
                end
              end
            end

            if scenario.see_new_declarations.any?
              it "should make prior declarations available to the new lead provider when they are different", skip: "Not yet implemented" do
                expect(subject).to find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.see_new_declarations
              end
            end
          end
        end

        context "Then other Lead Providers" do
          subject(:another_lead_provider) { "Another Lead Provider" }

          it do
            is_expected.to_not find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                     scenario.participant_email,
                                                                                     scenario.participant_trn,
                                                                                     "Original SIT's School",
                                                                                     scenario.participant_type
          end
          it { is_expected.to find_training_declarations_in_ecf_declarations_endpoint "the Participant", [] }
        end

        context "Then the Support for Early Career Teachers Service" do
          subject(:support_ects) { "Support for Early Career Teachers Service" }

          it { is_expected.to find_participant_details_in_the_ecf_users_endpoint "the Participant", scenario.participant_email, scenario.new_programme, scenario.participant_type }
        end

        context "Then a Teacher CPD Finance User" do
          subject(:finance_user) { create :user, :finance }

          xit "should be able to see who the participant is managed by, where there training is up to and what payments are due to each Lead Provider", :aggregate_failures do
            expect(subject).to be_able_to_find_the_school_of_the_participant_in_the_finance_portal "the Participant", "New SIT"
            if scenario.new_programme == "FIP"
              expect(subject).to be_able_to_find_the_lead_provider_of_the_participant_in_the_finance_portal "the Participant", scenario.new_lead_provider_name
            end
            expect(subject).to be_able_to_find_the_status_of_the_participant_in_the_finance_portal "the Participant", scenario.new_participant_status
            expect(subject).to be_able_to_find_the_training_status_of_the_participant_in_the_finance_portal "the Participant", scenario.new_training_status
            expect(subject).to be_able_to_find_the_training_declarations_for_the_participant_in_the_finance_portal "the Participant", scenario.see_new_declarations

            expect(subject).to be_able_to_see_recruitment_summary_for_lead_provider_in_payment_breakdown "Original Lead Provider", scenario.original_payment_ects, scenario.original_payment_mentors
            expect(subject).to be_able_to_see_payment_summary_for_lead_provider_in_payment_breakdown "Original Lead Provider", scenario.original_payment_declarations
            expect(subject).to be_able_to_see_started_declaration_payment_for_lead_provider_in_payment_breakdown "Original Lead Provider", scenario.original_payment_ects, scenario.original_payment_mentors, scenario.original_payment_declarations
            expect(subject).to be_able_to_see_other_fees_for_the_lead_provider_in_the_finance_portal "Original Lead Provider", scenario.original_payment_ects, scenario.original_payment_mentors

            expect(subject).to be_able_to_see_recruitment_summary_for_lead_provider_in_payment_breakdown "New Lead Provider", scenario.new_payment_ects, scenario.new_payment_mentors
            expect(subject).to be_able_to_see_payment_summary_for_lead_provider_in_payment_breakdown "New Lead Provider", scenario.new_payment_declarations
            expect(subject).to be_able_to_see_started_declaration_payment_for_lead_provider_in_payment_breakdown "New Lead Provider", scenario.new_payment_ects, scenario.new_payment_mentors, scenario.new_payment_declarations
            expect(subject).to be_able_to_see_other_fees_for_the_lead_provider_in_the_finance_portal "New Lead Provider", scenario.new_payment_ects, scenario.new_payment_mentors
          end
        end

        context "Then a Teacher CPD Admin User" do
          subject(:admin_user) { create :user, :admin }

          it { is_expected.to find_participant_details_in_support_portal "the Participant", "New SIT" }
        end

        context "Then the Analytics Dashboards" do
          subject(:analytics_user) { "Analysts" }

          it "is expected to report the correct participant details for \"the Participant\"", skip: "Not yet implemented" do
            expect(subject).to report_correct_participant_details "the Participant"
          end
        end
      end
    end
  end
end
