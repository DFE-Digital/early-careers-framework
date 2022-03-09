require "rails_helper"

RSpec.describe Statements::MarkAsPaid do
  subject(:service) { described_class.new(statement) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:payable_declaration) { create(:npq_participant_declaration, :payable) }
  let(:voided_declaration) { create(:npq_participant_declaration, :voided) }
  let(:statement) do
    create :npq_statement, cpd_lead_provider: cpd_lead_provider do |statement|
      statement.participant_declarations << payable_declaration
      statement.participant_declarations << voided_declaration
    end
  end

  describe "#call" do
    it "transitions the payable declarations to paid", :aggregate_failures do
      expect {
        expect { service.call }.to change(statement, :type).to("Finance::Statement::NPQ::Payable")
      }.to change(statement.participant_declarations.paid, :count).from(0).to(1)
    end
  end
end
