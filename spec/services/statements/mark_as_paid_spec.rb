# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:payable_declaration) { create(:npq_participant_declaration, :payable) }
  let(:voided_declaration) { create(:npq_participant_declaration, :voided) }
  let(:awaiting_clawback_declaration) { create(:npq_participant_declaration, :awaiting_clawback) }
  let(:statement) { create :npq_payable_statement, cpd_lead_provider: }

  before do
    Finance::StatementLineItem.create!(
      statement:,
      participant_declaration: payable_declaration,
      state: payable_declaration.state,
    )

    Finance::StatementLineItem.create!(
      statement:,
      participant_declaration: voided_declaration,
      state: voided_declaration.state,
    )

    Finance::StatementLineItem.create!(
      statement:,
      participant_declaration: awaiting_clawback_declaration,
      state: awaiting_clawback_declaration.state,
    )
  end

  subject { described_class.new(statement) }

  describe "#call" do
    it "transitions the statement itself" do
      expect {
        subject.call
      }.to change { Finance::Statement::NPQ::Payable.count }.by(-1)
      .and change { Finance::Statement::NPQ::Paid.count }.by(1)
    end

    describe "declarations" do
      it "transitions the payable to paid" do
        expect(statement.participant_declarations.payable.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.participant_declarations.paid, :count).from(0).to(1)
      end

      it "transitions the awaiting_clawback to clawed_back" do
        expect(statement.participant_declarations.awaiting_clawback.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.participant_declarations.clawed_back, :count).from(0).to(1)
      end
    end

    describe "line items" do
      it "transitions the payable to paid" do
        expect(statement.statement_line_items.payable.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.statement_line_items.paid, :count).from(0).to(1)
      end

      it "transitions the awaiting_clawback to clawed_back" do
        expect(statement.statement_line_items.awaiting_clawback.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.statement_line_items.clawed_back, :count).from(0).to(1)
      end
    end
  end
end
