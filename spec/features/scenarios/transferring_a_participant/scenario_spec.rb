# frozen_string_literal: true

require "rails_helper"
require_relative "./scenario"

RSpec.feature "Transfer a participant", type: :feature do
  include Steps::TransferParticipantSteps

  let(:cohort) { create :cohort, :current }
  let(:privacy_policy)  { create :privacy_policy }

  let(:lead_providers)  { {} }
  let(:tokens) { {} }
  let(:sits) { {} }

  before do
    create(:ecf_schedule)
  end

  filepath = File.join(File.dirname(__FILE__), "./scenarios.csv")
  CSV.parse(File.read(filepath), headers: true).each_with_index do |data, index|
    scenario = Scenario.new index + 2, data

    # NOTE: uncomment to specify a specific test to run
    # next unless index + 2 == 13

    context "#{scenario.number}. Given a #{scenario.participant_type} is to transfer off a #{scenario.original_programme} onto a #{scenario.new_programme}#{' using a different provider' if scenario.transfer == :different_provider}#{' using the same provider' if scenario.transfer == :same_provider}" do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "New Lead Provider"
        given_lead_providers_contracted_to_deliver_ecf "Another Lead Provider"

        and_sit_reported_programme "Original SIT", scenario.original_programme
        if scenario.original_programme == "FIP"
          and_lead_provider_reported_partnership "Original Lead Provider", "Original SIT"
        end

        and_sit_reported_programme "New SIT", scenario.new_programme
        if scenario.new_programme == "FIP"
          case scenario.transfer
          when :same_provider
            and_lead_provider_reported_partnership "Original Lead Provider", "New SIT"
          else
            and_lead_provider_reported_partnership "New Lead Provider", "New SIT"
          end
        end

        and_sit_reported_participant "Original SIT", "the Participant", scenario.participant_type
        and_participant_has_completed_registration "the Participant"

        expect(sits["Original SIT"]).to be_able_to_find_the_status_of_the_participant_in_the_school_induction_portal "the Participant", scenario.starting_school_status
      end

      context "When they are transferred by the new SIT#{" after the declarations #{scenario.prior_declarations} have been made" if scenario.prior_declarations.any?}#{" and the new declarations #{scenario.new_declarations} are then made" if scenario.new_declarations.any?}#{' before any declarations are made' if (scenario.new_declarations + scenario.prior_declarations).empty?}" do
        before do
          scenario.prior_declarations.each do |declaration_type|
            and_lead_provider_has_made_training_declaration "Original Lead Provider", "the Participant", declaration_type
          end

          expect(sits["Original SIT"]).to be_able_to_find_the_status_of_the_participant_in_the_school_induction_portal "the Participant", scenario.prior_school_status

          when_sit_takes_on_the_participant "New SIT", "the Participant"

          scenario.new_declarations.each do |declaration_type|
            declaring_lead_provider = scenario.transfer == :same_provider ? "Original Lead Provider" : "New Lead Provider"
            and_lead_provider_has_made_training_declaration declaring_lead_provider, "the Participant", declaration_type
          end
        end

        context "Then the Original SIT" do
          subject(:original_sit) { sits["Original SIT"] }

          it { should_not be_able_to_find_the_details_of_the_participant_in_the_school_induction_portal "the Participant" }
        end

        context "Then the New SIT" do
          subject(:new_sit) { sits["New SIT"] }

          it { should be_able_to_find_the_details_of_the_participant_in_the_school_induction_portal "the Participant" }
          it { should be_able_to_find_the_status_of_the_participant_in_the_school_induction_portal "the Participant", scenario.new_school_status }

          # what are the onward actions available to the new school - can they do them ??
        end

        context "Then the Original Lead Provider" do
          subject(:original_lead_provider) { "Original Lead Provider" }

          case scenario.see_original_details
          when :ALL
            it { should be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.participant_type }
            it { should be_able_to_retrieve_the_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.prior_participant_status }
            it { should be_able_to_retrieve_the_training_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.prior_training_status }
          when :OBFUSCATED
            it "is expected to be able to retrieve the obfuscated details of the participant from the ecf participants endpoint",
               skip: "Not yet implemented" do
              # should be_able_to_retrieve_the_obfuscated_details_of_the_participant_from_the_ecf_participants_endpoint "Original Lead Provider"
            end
            it "is expected to be able to retrieve the status '#{scenario.prior_participant_status}' of the participant from the ecf participants endpoint",
               skip: "Not yet implemented" do
              # should be_able_to_retrieve_the_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.prior_participant_status }
            end
            it "is expected to be able to retrieve the training status '#{scenario.prior_training_status}' of the participant from the ecf participants endpoint",
               skip: "Not yet implemented" do
              # should be_able_to_retrieve_the_training_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.prior_training_status }
            end
          else
            it { should_not be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.participant_type }
          end

          case scenario.see_original_declarations
          when :PRIOR_ONLY
            it { should be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", scenario.prior_declarations }
          when :ALL
            it { should be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", scenario.prior_declarations + scenario.new_declarations }
          end

          # previous lead provider can void ??
        end

        context "Then the New Lead Provider" do
          subject(:new_lead_provider) { "New Lead Provider" }

          case scenario.see_new_details
          when :ALL
            it { should be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.participant_type }
            it { should be_able_to_retrieve_the_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.new_participant_status }
            it { should be_able_to_retrieve_the_training_status_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.new_training_status }
          end

          scenario.duplicate_declarations.each do |declaration_type|
            it { should be_blocked_from_making_a_duplicate_training_declaration_for_the_participant "the Participant", declaration_type }
          end

          case scenario.see_new_declarations
          when :ALL
            if scenario.new_declarations.empty?
              it "is expected to have their declarations made available",
                 skip: "Not implemented yet" do
                should be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", scenario.prior_declarations
              end
            else
              it { should be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", scenario.prior_declarations + scenario.new_declarations }
            end
          end
        end

        context "Then other Lead Providers" do
          subject(:another_lead_provider) { "Another Lead Provider" }

          it { should_not be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint "the Participant", scenario.participant_type }
          it { should be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", [] }
        end

        context "Then the Support for Early Career Teachers Service" do
          subject(:support_ects) { "Support for Early Career Teachers Service" }

          it { should be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_users_endpoint "the Participant", scenario.new_programme, scenario.participant_type }
        end

        context "Then a Teacher CPD Finance User" do
          subject(:finance_user) { create :user, :finance }

          it { should be_able_to_find_the_school_of_the_participant_in_the_finance_portal "the Participant", "New SIT" }
          it { should be_able_to_find_the_status_of_the_participant_in_the_finance_portal "the Participant", scenario.new_participant_status }
          it { should be_able_to_find_the_training_status_of_the_participant_in_the_finance_portal "the Participant", scenario.new_training_status }
          it { should be_able_to_find_the_training_declarations_for_the_participant_in_the_finance_portal "the Participant", scenario.prior_declarations + scenario.new_declarations }

          case scenario.transfer
          when :same_provider
            it { should be_able_to_find_the_lead_provider_of_the_participant_in_the_finance_portal "the Participant", "Original Lead Provider" }
          when :different_provider
            it { should be_able_to_find_the_lead_provider_of_the_participant_in_the_finance_portal "the Participant", "New Lead Provider" }
            it { should_not be_able_to_find_the_lead_provider_of_the_participant_in_the_finance_portal "the Participant", "Original Lead Provider" }
          end
          it { should_not be_able_to_find_the_lead_provider_of_the_participant_in_the_finance_portal "the Participant", "Another Lead Provider" }

          it "can see the payment breakdown", skip: "not working" do
            sign_in_as finance_user

            lead_provider_name = "New Lead Provider"

            # request payment breakdown report
            click_on "Payment Breakdown"

            # PaymentBreakdownReportWizard.new lead_provider_name

            # choose_ecf_programme "ECF payments"
            choose "ECF payments"
            click_on "Continue"

            # choose_lead_provider "Original Lead Provider"
            choose lead_provider_name
            click_on "Continue"

            puts "====="

            # Statement of fact
            # Original Lead Provider
            # Payment of
            # £22,287.90
            # On 11 March 2022
            # Submission deadline 9 February 2022
            # Current ECTs 0 Current Mentors 0 Total 0 Recruitment target 2000
            # Payment Breakdown
            # Payment type Number of declarations Payment amount for period Service fee 2000 £22,287.90 Output fee 0 £0.00 Uplift fee 0 £0.00 VAT £4,457.58 Total payment £26,745.48
            # Service fees Band Fee per participant Current participants Payment Band A £323.17 2000 £22,287.90 Band B £391.60 0 £0.00 Band C £386.40 0 £0.00
            # Output fees - started Band Fee per participant Current participants Payment Band A £119.40 0 £0.00 Band B £117.48 0 £0.00 Band C £115.92 0 £0.00
            # Output fees - retained 1 Band Fee per participant Current participants Payment Band A £89.55 0 £0.00 Band B £88.11 0 £0.00 Band C £86.94 0 £0.00
            # Particiant Breakdown Milestone Number of participants Total paid Total not paid Started 0 0 Retained 1 0 0
            # Other fees - started Type Fee per participant Number of participants Payment Uplift fee £100.00 0 £0.00
            # View voided declarations View contract information

            puts page.find("main").text

            puts "====="

            cpd_lead_provider = lead_providers[lead_provider_name]
            lead_provider = cpd_lead_provider.lead_provider

            nov_statement = Finance::Statement::ECF.find_by!(name: "November 2021", cpd_lead_provider: cpd_lead_provider)
            nov_starts = Finance::ECF::CalculationOrchestrator.new(
              statement: nov_statement,
              contract: lead_provider.call_off_contract,
              aggregator: Finance::ECF::ParticipantAggregator.new(statement: nov_statement),
              calculator: PaymentCalculator::ECF::PaymentCalculation,
            ).call(event_type: :started)

            puts page.find("main").text

            puts "====="

            puts JSON.pretty_generate nov_starts

            sign_out
          end
        end

        # TODO: what would analytics have gathered ??
        # TODO: what can admin / support users see ??
      end
    end
  end
end
