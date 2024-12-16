# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  let(:cpd_lead_provider)             { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:cohort)                        { Cohort.current }
  let(:eligible_statement)            { create(:npq_statement, cpd_lead_provider:, cohort:, deadline_date: Cohort.next.registration_start_date - 3.months) }
  let(:statement)                     { create(:npq_statement, cpd_lead_provider:, cohort:, deadline_date: Cohort.next.registration_start_date - 2.months) }

  subject { described_class.new(statement) }

  before do
    Statements::MarkAsPayable.new(eligible_statement).call
    Statements::MarkAsPaid.new(eligible_statement).call

    travel_to statement.deadline_date - 1.day do
      create(:npq_participant_declaration, :eligible, cpd_lead_provider:)
      VoidParticipantDeclaration.new(create(:npq_participant_declaration, :eligible, cpd_lead_provider:)).call
    end
    Statements::MarkAsPayable.new(statement).call
    Finance::Statement::NPQ::Payable.find(statement.id)
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
    end

    describe "line items" do
      it "transitions the payable to paid" do
        expect(statement.statement_line_items.payable.count).to eql(1)

        expect {
          subject.call
        }.to change(statement.reload.statement_line_items.paid, :count).from(0).to(1)
      end
    end

    context "when `disable_npq` feature flag is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not transition the statement, declarations and line items" do
        expect {
          subject.call
          statement.reload
        }.to not_change { statement.type }
        .and(not_change { statement.participant_declarations.paid.count })
        .and(not_change { statement.statement_line_items.paid.count })
      end
    end
  end
end
