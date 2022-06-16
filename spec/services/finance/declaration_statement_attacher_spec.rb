# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::DeclarationStatementAttacher do
  let(:declaration) { create(:ect_participant_declaration, cpd_lead_provider:) }
  let(:statement) { create(:ecf_statement, output_fee: true, deadline_date: 2.months.from_now) }
  let(:cpd_lead_provider) { statement.cpd_lead_provider }

  subject { described_class.new(participant_declaration: declaration) }

  describe "#call" do
    it "creates line item" do
      expect {
        subject.call
      }.to change { statement.reload.statement_line_items.count }.by(1)
    end

    it "create line item with same state as declaration" do
      subject.call

      line_item = Finance::StatementLineItem.last
      expect(line_item.state).to eql(declaration.state)
    end
  end
end
