# frozen_string_literal: true

require "rails_helper"
require_relative "./changes_of_circumstance_scenario"

def given_context(scenario)
  str = "[#{scenario.number}]"
  str += " Given a #{scenario.participant_type}"
  str += " on #{scenario.original_programme} is to be onboarded to #{scenario.new_programme}"
  str += " using the Same Provider" if scenario.transfer == :same_provider
  str += " using a Different Provider" if scenario.transfer == :different_provider
  str
end

def when_context(scenario)
  str = "When they are onboarded by the new SIT"
  str += " after being withdrawn by #{scenario.withdrawn_by}"
  str += " before any declarations are made" if (scenario.new_declarations + scenario.prior_declarations).empty?
  str += " after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?
  str += " and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?
  str
end

RSpec.feature "Onboard a withdrawn participant", type: :feature, end_to_end_scenario: true do
  include Steps::ChangesOfCircumstanceSteps

  includes = ENV.fetch("SCENARIOS", "").split(",").map(&:to_i)

  fixture_data_path = File.join(File.dirname(__FILE__), "./onboarding_a_withdrawn_participant_fixtures.csv")
  CSV.parse(File.read(fixture_data_path), headers: true).each_with_index do |fixture_data, index|
    next if includes.any? && !includes.include?(index + 2)

    scenario = ChangesOfCircumstanceScenario.new index + 2, fixture_data

    let(:cohort) { create :cohort, :current }
    let(:privacy_policy) { create :privacy_policy }

    let(:tokens) { {} }

    before do
      and_feature_flag_is_active :eligibility_notifications
      and_feature_flag_is_active :change_of_circumstances

      create :ecf_schedule
    end

    context given_context(scenario) do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "New Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

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

        and_sit_reported_participant "Original SIT", "the Participant", scenario.participant_email, scenario.participant_type
        and_participant_has_completed_registration "the Participant", scenario.participant_type
      end

      context when_context(scenario) do
        before do
          scenario.prior_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "Original Lead Provider", scenario.participant_type, "the Participant", declaration_type
          end

          case scenario.withdrawn_by
          when :lead_provider
            and_lead_provider_withdraws_participant "Original Lead Provider", "the Participant", scenario.participant_type
          when :school
            and_school_withdraws_participant "Original SIT", "the Participant"
          when :not_applicable
            # not applicable
          else
            raise "scenario.withdrawn_by is not a valid value"
          end

          when_school_takes_on_the_withdrawn_participant "New SIT", "the Participant"

          scenario.new_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration scenario.new_lead_provider_name, scenario.participant_type, "the Participant", declaration_type
          end

          and_eligible_training_declarations_are_made_payable

          and_lead_provider_statements_have_been_created "Original Lead Provider"
          and_lead_provider_statements_have_been_created "New Lead Provider"
          and_lead_provider_statements_have_been_created "Another Lead Provider"
        end

        context "Then the Original SIT" do
          subject(:original_sit) { "Original SIT" }

          it { should_not find_participant_details_in_school_induction_portal "the Participant" }
        end

        context "Then the New SIT" do
          subject(:new_sit) { "New SIT" }

          it { should find_participant_details_in_school_induction_portal "the Participant", scenario.new_school_status }

          # what are the onward actions available to the new school - can they do them ??
        end

        if scenario.original_programme == "FIP"
          context "Then the Original Lead Provider" do
            subject(:original_lead_provider) { "Original Lead Provider" }

            case scenario.see_original_details
            when :ALL
              it {
                should find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                             scenario.participant_email,
                                                                             scenario.participant_type,
                                                                             scenario.prior_participant_status,
                                                                             scenario.prior_training_status
                # experimental: true
              }
            when :OBFUSCATED
              it.pending do
                should find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                             nil,
                                                                             scenario.participant_type
                #  experimental: true
              end
            else
              it {
                should_not find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                                 scenario.participant_email,
                                                                                 scenario.participant_type
                # experimental: true
              }
            end

            if scenario.see_original_declarations.any?
              it { should find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.see_original_declarations }
            elsif scenario.all_declarations.any?
              it { should_not find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.all_declarations }
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
                should find_participant_details_in_ecf_participants_endpoint "the Participant",
                                                                             scenario.participant_email,
                                                                             scenario.participant_type,
                                                                             scenario.new_participant_status,
                                                                             scenario.new_training_status
                # experimental: true
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
              # TODO: make prior declarations available to the different lead provider
              it.pending { should find_training_declarations_in_ecf_declarations_endpoint "the Participant", scenario.see_new_declarations }
            end
          end
        end

        context "Then other Lead Providers" do
          subject(:another_lead_provider) { "Another Lead Provider" }

          it { should_not find_participant_details_in_ecf_participants_endpoint "the Participant", scenario.participant_email, scenario.participant_type }
          it { should find_training_declarations_in_ecf_declarations_endpoint "the Participant", [] }
        end

        context "Then the Support for Early Career Teachers Service" do
          subject(:support_ects) { "Support for Early Career Teachers Service" }

          it { should find_participant_details_in_the_ecf_users_endpoint "the Participant", scenario.participant_email, scenario.new_programme, scenario.participant_type }
        end

        context "Then a Teacher CPD Finance User" do
          subject(:finance_user) { create :user, :finance }

          it "should be able to see who the participant is managed by, where there training is up to and what payments are due to each Lead Provider", :aggregate_failures do
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

          it { should find_participant_details_in_support_portal "the Participant", "New SIT" }
        end

        context "Then the Analytics Dashboards" do
          subject(:analytics_user) { "Analysts" }

          it.pending { should report_correct_participant_details "the Participant" }
        end
      end
    end
  end
end
