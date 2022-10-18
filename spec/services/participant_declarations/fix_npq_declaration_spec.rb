# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclarations::FixNPQDeclaration, :with_default_schedules do
  let(:cpd_lead_provider)        { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:ecf_statement)            { participant_declaration.statements.first }
  let(:npq_statement)            { create(:npq_statement, :output_fee, cpd_lead_provider:) }
  let!(:participant_declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }

  before do
    travel_to ecf_statement.deadline_date { participant_declaration }
  end

  describe "#call" do
    it "moves the declaration to the NPQ statement and flip the type to NPQ" do
      expect {
        described_class.new(ecf_statement, npq_statement).call(participant_declaration)
      }.to change(ecf_statement.participant_declarations, :count).from(1).to(0)
       .and change(npq_statement.participant_declarations, :count).from(0).to(1)
    end
  end
end
