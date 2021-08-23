# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantEventAggregator do
  let(:lead_provider) { create(:lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }

  context "event declarations" do
    describe ".call" do
      context "aggregate using ParticipantDeclaration" do
        it "returns a count of the unique started events" do
          10.times do
            participant_declaration = create(:ect_participant_declaration, cpd_lead_provider: cpd_lead_provider, payable: true)
            create(:ect_participant_declaration, user: participant_declaration.user, cpd_lead_provider: cpd_lead_provider, payable: true)
          end

          expect(described_class.call(cpd_lead_provider: cpd_lead_provider)).to eq(10)
        end

        it "does not include non-payable events" do
          create_list(:ect_participant_declaration, 2, cpd_lead_provider: cpd_lead_provider, payable: true)
          create_list(:ect_participant_declaration, 2, cpd_lead_provider: cpd_lead_provider, payable: false)

          expect(described_class.call(cpd_lead_provider: cpd_lead_provider)).to eq(2)
        end
      end

      it "can be injected with a different recorder" do
        create(:npq_course)
        create_list(:npq_participant_declaration, 5, cpd_lead_provider: cpd_lead_provider, payable: true)
        expect(described_class.call(recorder: ParticipantDeclaration::NPQ, cpd_lead_provider: cpd_lead_provider)).to eq(5)
      end

      it "can be injected with a different recorder and different scope" do
        create(:npq_course)
        2.times do
          participant_declaration = create(:mentor_participant_declaration, cpd_lead_provider: cpd_lead_provider, payable: true)
          create(:npq_participant_declaration, user: participant_declaration.user, cpd_lead_provider: cpd_lead_provider, payable: true)
        end

        expect(described_class.call(recorder: ParticipantDeclaration::NPQ, scope: :active_npqs_for_lead_provider, cpd_lead_provider: cpd_lead_provider)).to eq(2)
      end
    end
  end
end
