require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  subject(:service) { described_class.new(statement) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:payable_declaration) { create(:npq_participant_declaration, :payable) }
  let(:voided_declaration) { create(:npq_participant_declaration, :voided) }
  let(:statement) do
    create :npq_statement,
           cpd_lead_provider: cpd_lead_provider,
           particiant_declarations: [payable_declaration, voided_declaration]
  end

  it "transitions the payable declarations to paid" do
    expect {
      described_class.call
    }.to change(statement.participant_declarations, :paid).from(0, 1)
  end
end
