# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPayable do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }

  let(:submitted_declaration) { create(:npq_participant_declaration, :submitted) }
  let(:eligible_declaration) { create(:npq_participant_declaration, :eligible) }

  let(:awaiting_clawback_declaration) { create(:npq_participant_declaration, :awaiting_clawback_declaration) }

  let(:ineligible_declaration) { create(:npq_participant_declaration, :ineligible) }
  let(:voided_declaration) { create(:npq_participant_declaration, :voided) }

  let(:statement) { create :npq_statement, cpd_lead_provider: }

  before do
    [
      submitted_declaration,
      eligible_declaration,
      ineligible_declaration,
      voided_declaration,
    ].each do |participant_declaration|
      Finance::StatementLineItem.create!(
        statement:,
        participant_declaration:,
        state: participant_declaration.state,
      )
    end
  end

  subject { described_class.new(statement:) }

  describe "#call" do
    it "transitions declarations" do
      expect {
        subject.call
        statement.reload
      }.to  not_change(statement.participant_declarations, :count)
       .and not_change(statement.participant_declarations.submitted, :count)
       .and change(statement.participant_declarations.eligible, :count).from(1).to(0)
       .and change(statement.participant_declarations.payable, :count).from(0).to(1)
       .and not_change(statement.participant_declarations.awaiting_clawback, :count)
       .and not_change(statement.participant_declarations.ineligible, :count)
       .and not_change(statement.participant_declarations.voided, :count)
    end

    it "transitions line items" do
      expect {
        subject.call
        statement.reload
      }.to  not_change(statement.statement_line_items, :count)
       .and not_change(statement.statement_line_items.submitted, :count)
       .and change(statement.statement_line_items.eligible, :count).from(1).to(0)
       .and change(statement.statement_line_items.payable, :count).from(0).to(1)
       .and not_change(statement.statement_line_items.awaiting_clawback, :count)
       .and not_change(statement.statement_line_items.ineligible, :count)
       .and not_change(statement.statement_line_items.voided, :count)
    end
  end
end
