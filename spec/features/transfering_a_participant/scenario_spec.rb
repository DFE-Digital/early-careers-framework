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
  let(:participants) { {} }

  let(:original_lead_provider) { "Original Lead Provider" }
  let(:new_lead_provider) { "New Lead Provider" }
  let(:another_lead_provider) { "Another Lead Provider" }

  let(:original_sit) { "Original SIT" }
  let(:new_sit) { "New SIT" }

  subject(:participant) { "the ECT" }

  filepath = File.join(File.dirname(__FILE__), "./scenarios.csv")
  CSV.parse(File.read(filepath), headers: true).each_with_index do |data, index|
    scenario = Scenario.new index + 2, data

    context "#{scenario.number}. Given a #{scenario.participant_type} is to transfer off a #{scenario.original_programme} onto a #{scenario.new_programme}#{scenario.transfer == :different_provider ? ' using a different provider' : ' using the same provider'}" do
      before do
        given_lead_providers_contracted_to_deliver_ecf original_lead_provider, new_lead_provider, another_lead_provider

        and_sit_reported_programme original_sit, scenario.original_programme
        if scenario.original_programme == "FIP"
          and_lead_provider_reported_partnership original_lead_provider, original_sit
        end

        and_sit_reported_programme new_sit, scenario.new_programme
        if scenario.new_programme == "FIP"
          case scenario.transfer
          when :same_provider
            and_lead_provider_reported_partnership original_lead_provider, new_sit
          when :different_provider
            and_lead_provider_reported_partnership new_lead_provider, new_sit
          else
            and_lead_provider_reported_partnership new_lead_provider, new_sit
          end
        end

        and_sit_reported_ect_participant original_sit, participant, scenario.participant_type
      end

      context "When they are transferred by the new SIT#{' after declarations have been made' if scenario.prior_declarations.any?}#{' and new declarations are then made' if scenario.new_declarations.any?}" do
        before do
          scenario.prior_declarations.each do |declaration_type|
            and_lead_provider_declared_training_started original_lead_provider, participant, declaration_type
          end

          when_sit_takes_on_the_participant new_sit, participant

          scenario.new_declarations.each do |declaration_type|
            declaring_lead_provider = scenario.transfer == :same_provider ? original_lead_provider : new_lead_provider
            and_lead_provider_declared_training_started declaring_lead_provider, participant, declaration_type
          end
        end

        context "Then in the Schools Portal the ECT" do
          it { should_not be_seen_by_sit original_sit }
          # it { should have_the_status_reported_to_sit original_sit, scenario.prior_school_status
          # it { should have_the_training_status_reported_to_sit original_sit, scenario.prior_training_status

          it { should be_seen_by_sit new_sit }
          # it { should have_the_status_reported_to_sit new_sit, scenario.prior_school_status
          # it { should have_the_training_status_reported_to_sit new_sit, scenario.prior_training_status

          # what are the onward actions available to new school - what are they ??
        end

        context "Then in the Original Lead Provider API the ECT" do
          case scenario.see_original_details
          when :ALL
            it { should have_their_details_made_available_to original_lead_provider }
          when :OBFUSCATED
            it "is expected to have their details obfuscated from Original Lead Provider",
               skip: "Not yet implemented" do
              # should_not have_their_details_obfuscated_from original_lead_provider
            end
          else
            it { should_not have_their_details_made_available_to original_lead_provider }
          end

          case scenario.see_original_declarations
          when :PRIOR_ONLY
            it { should have_their_declarations_made_available_to original_lead_provider, scenario.prior_declarations }
          when :ALL
            it { should have_their_declarations_made_available_to original_lead_provider, scenario.prior_declarations + scenario.new_declarations }
          end

          # what status should be seen by original LP
          # what training_status should be seen by original LP

          # previous lead provider can void ??
        end

        context "Then in the New Lead Provider API the ECT" do
          case scenario.see_new_details
          when :ALL
            it { should have_their_details_made_available_to new_lead_provider }
          end

          case scenario.see_new_declarations
          when :ALL
            if scenario.new_declarations.empty?
              it "is expected to have their declarations made available",
                 skip: "Not implemented yet" do
                should have_their_declarations_made_available_to new_lead_provider, scenario.prior_declarations
              end
            else
              it { should have_their_declarations_made_available_to new_lead_provider, scenario.prior_declarations + scenario.new_declarations }
            end
          end

          # what status should be seen by new LP
          # what training_status should be seen by new LP
        end

        context "Then in other Lead Providers APIs the ECT" do
          it { should_not have_their_details_made_available_to another_lead_provider }
          it { should_not have_their_declarations_made_available_to another_lead_provider }
        end

        context "Then in the Support for ECTs API the ECT" do
          it { should be_reported_to_support_for_ect_as scenario.new_programme, scenario.participant_type }
        end

        # what can admins see ??
        # would they appear in the payment break down at this point ??
        # what can support users see ??
        # what would analytics have triggered ??
      end
    end
  end
end
