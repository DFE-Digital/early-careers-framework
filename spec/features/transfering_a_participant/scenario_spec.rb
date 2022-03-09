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

    # next unless index + 2 == 8

    context "#{scenario.number}. Given a #{scenario.participant_type} is to transfer off a #{scenario.original_programme} onto a #{scenario.new_programme}#{' using a different provider' if scenario.transfer == :different_provider}#{' using the same provider' if scenario.transfer == :same_provider}" do
      before do
        given_lead_providers_contracted_to_deliver_ecf "Original Lead Provider",
                                                       "New Lead Provider",
                                                       "Another Lead Provider"

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

      context "When they are transferred by the new SIT#{' after declarations have been made' if scenario.prior_declarations.any?}#{' and new declarations are then made' if scenario.new_declarations.any?}#{' before any declarations are made' if (scenario.new_declarations + scenario.prior_declarations).empty?}" do
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
          it { should_not be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint "the Participant", [] }
        end

        context "Then the Support for Early Career Teachers Service" do
          subject(:support_ects) { "Support for Early Career Teachers Service" }

          it { should be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_users_endpoint "the Participant", scenario.new_programme, scenario.participant_type }
        end

        # TODO: would they appear in the payment break down at this point ??
        # TODO: what would analytics have gathered ??
        # TODO: what can admin / support users see ??
      end
    end
  end
end
