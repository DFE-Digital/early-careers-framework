# frozen_string_literal: true

RSpec.describe Finance::DeclarationStatementAttacher, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

  let(:declaration) do
    create(:ect_participant_declaration, :eligible, cpd_lead_provider:)
  end

  let!(:statement) do
    create(:ecf_statement, output_fee: true, deadline_date: 2.months.from_now, cpd_lead_provider:)
  end

  subject { described_class.new(declaration) }

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
