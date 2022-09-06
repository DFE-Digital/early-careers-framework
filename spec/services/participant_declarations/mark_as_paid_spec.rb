# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclarations::MarkAsPaid, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:statement) { create :ecf_statement, :next_output_fee, cpd_lead_provider: }

  subject { described_class.new(statement) }

  describe "#call" do
    let!(:participant_declaration) do
      travel_to statement.deadline_date do
        create(:ect_participant_declaration, declaration_state, cpd_lead_provider:)
      end
    end

    context "when the participant declaration is payable" do
      let(:declaration_state) { :payable }

      it "transitions the declaration to paid" do
        expect(participant_declaration).to be_payable
        expect(participant_declaration.statement_line_items.payable.count).to eq(1)
        expect(participant_declaration.statement_line_items.paid).not_to exist

        subject.call(participant_declaration)

        participant_declaration.reload
        expect(participant_declaration).to be_paid
        expect(participant_declaration.statement_line_items.payable).not_to exist
        expect(participant_declaration.statement_line_items.paid.count).to eq(1)
      end
    end

    context "when the participant declaration is eligible" do
      let(:declaration_state) { :eligible }

      it "does not the declaration to paid" do
        expect(participant_declaration).to be_eligible

        expect {
          subject.call(participant_declaration)
        }.not_to change(participant_declaration.statement_line_items, :count)

        participant_declaration.reload
        expect(participant_declaration).to be_eligible
      end
    end

    context "when the participant declaration is eligible" do
      let(:declaration_state) { :awaiting_clawback }

      it "does not transitions declaration to paid" do
        expect(participant_declaration).to be_awaiting_clawback
        expect(participant_declaration.statement_line_items.awaiting_clawback.count).to eq(1)
        expect(participant_declaration.statement_line_items.paid.count).to eq(1)

        expect {
          subject.call(participant_declaration)
        }.not_to change(participant_declaration.statement_line_items, :count)

        expect(participant_declaration).to be_awaiting_clawback
      end
    end

    context "when the participant declaration is eligible" do
      let(:declaration_state) { :clawed_back }

      it "does not transitions the declaration to paid" do
        expect(participant_declaration).to be_clawed_back
        expect(participant_declaration.statement_line_items.clawed_back.count).to eq(1)
        expect(participant_declaration.statement_line_items.paid.count).to eq(1)

        expect {
          subject.call(participant_declaration)
        }.not_to change(participant_declaration.statement_line_items, :count)

        expect(participant_declaration).to be_clawed_back
      end
    end
  end
end
