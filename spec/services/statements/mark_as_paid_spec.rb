# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  let(:cpd_lead_provider)             { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:cohort)                        { Cohort.current }
  let(:eligible_statement)            { create(:npq_statement, cpd_lead_provider:, cohort:, deadline_date: 3.months.ago) }
  let(:statement)                     { create(:npq_statement, cpd_lead_provider:, cohort:, deadline_date: 2.months.ago) }
  let(:awaiting_clawback_declaration) { create(:npq_participant_declaration, :eligible, cpd_lead_provider:) }

  subject { described_class.new(statement) }

  before do
    travel_to eligible_statement.deadline_date - 1.day do
      awaiting_clawback_declaration
    end
    Statements::MarkAsPayable.new(eligible_statement).call
    Statements::MarkAsPaid.new(eligible_statement).call

    travel_to statement.deadline_date - 1.day do
      create(:npq_participant_declaration, :eligible, cpd_lead_provider:)
      VoidParticipantDeclaration.new(create(:npq_participant_declaration, :eligible, cpd_lead_provider:)).call
      Finance::ClawbackDeclaration.new(awaiting_clawback_declaration.reload).call
    end
    Statements::MarkAsPayable.new(statement).call
    statement.reload
  end

  describe "#call" do
    it "transitions the statement itself" do
      expect { subject.call }
        .to change(statement, :type).from("Finance::Statement::NPQ::Payable").to("Finance::Statement::NPQ::Paid")
    end

    describe "declarations" do
      it "transitions the payable to paid" do
        expect(statement.participant_declarations.payable.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.participant_declarations.paid, :count).from(0).to(1)
      end

      it "transitions the awaiting_clawback to clawed_back" do
        expect(statement.participant_declarations.awaiting_clawback.count).to eq(1)

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
