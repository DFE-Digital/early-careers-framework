# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoidParticipantDeclaration, :with_default_schedules do
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider) }
  let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
  let(:another_cpd_lead_provider) { create(:cpd_lead_provider) }

  before do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      output_fee: true,
      deadline_date: 3.months.from_now,
    )
  end

  describe "#call" do
    let(:participant_declaration) do
      create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
    end

    subject do
      described_class.new(participant_declaration:)
    end

    it "voids a participant declaration" do
      subject.call
      expect(participant_declaration.reload).to be_voided
    end

    it "does not void a voided declaration" do
      subject.call

      expect {
        subject.call
      }.to raise_error Api::Errors::InvalidTransitionError
    end

    context "when declaration is payable" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          :payable,
          cpd_lead_provider:,
          participant_profile:,
        )
      end

      it "can be voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
      end
    end

    context "when declaration is paid" do
      let!(:next_statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: 3.months.from_now) }
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          :paid,
          participant_profile:,
          cpd_lead_provider:,
        )
      end

      it "transitions to awaiting_clawback" do
        subject.call
        expect(participant_declaration.reload).to be_awaiting_clawback
      end
    end

    context "when declaration is submitted" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          user:,
          cpd_lead_provider:,
          declaration_date:,
          participant_profile: profile,
          state: "submitted",
        )
      end

      it "can be voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
      end
    end

    context "when declaration is attached to a statement" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          :payable,
          cpd_lead_provider:,
          participant_profile:,
        )
      end

      let(:line_item) { participant_declaration.statement_line_items.first }

      it "update line item state to voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
        expect(line_item.reload).to be_voided
      end
    end
  end
end
