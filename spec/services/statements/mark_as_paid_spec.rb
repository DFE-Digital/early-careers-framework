# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:payable_declaration) { create(:npq_participant_declaration, :payable) }
  let(:voided_declaration) { create(:npq_participant_declaration, :voided) }
  let(:statement) { create :npq_statement, cpd_lead_provider: cpd_lead_provider }

  before do
    Finance::StatementLineItem.create!(
      statement: statement,
      participant_declaration: payable_declaration,
      state: payable_declaration.state,
    )

    Finance::StatementLineItem.create!(
      statement: statement,
      participant_declaration: voided_declaration,
      state: voided_declaration.state,
    )
  end

  subject { described_class.new(statement) }

  describe "#call" do
    it "transitions the payable declarations to paid" do
      expect {
        subject.call
      }.to change(statement.reload.participant_declarations.paid, :count).from(0).to(1)
    end

    it "transitions the payable line items to paid" do
      expect {
        subject.call
      }.to change(statement.reload.statement_line_items.paid, :count).from(0).to(1)
    end
  end
end
