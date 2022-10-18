require "rails_helper"

RSpec.describe ParticipantDeclarations::FixNPQDeclaration, :with_default_schedules do
  let(:cpd_lead_provider)       { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:ecf_statement)           { create(:ecf_statement, cpd_lead_provider:) }
  let(:npq_statement)           { create(:npq_statement, cpd_lead_provider:) }
  let(:participant_declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }

  before do
    travel_to ecf_statement.deadline_date { participant_declaration }
  end

  describe "#call" do
    it "moves the declaration to the NPQ statement and flip the type to NPQ" do
      pp ecf_statement
      pp npq_statement
      pp participant_declaration.statement_line_items
      expect do
        described_class.new(ecf_statement, npq_statement).call(participant_declaration)
        pp Finance::StatementLineItem.all
      end
        .to change(participant_declaration.reload.statement_line_items.first, :statement_id).from(ecf_statement.id).to(npq_statement.id)
        .and change(participant_declaration, :type).from("ParticipantDeclaration::ECF").to("ParticipantDeclaration::NPQ")
    end
  end
end
