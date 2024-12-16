# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statements::MarkAsPayable do
  let(:cpd_lead_provider)              { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement)                     { create(:ecf_statement, :next_output_fee, cpd_lead_provider:) }
  let!(:submitted_declaration)         { create(:ect_participant_declaration, :submitted,  cpd_lead_provider:) }
  let!(:eligible_declaration)          { create(:ect_participant_declaration, :submitted,  cpd_lead_provider:) }
  let!(:ineligible_declaration)        { create(:ect_participant_declaration, :ineligible, cpd_lead_provider:) }
  let!(:voided_declaration)            { create(:ect_participant_declaration, :voided,     cpd_lead_provider:) }

  subject { described_class.new(statement) }

  before do
    travel_to statement.deadline_date do
      RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile
        .call(participant_profile: eligible_declaration.participant_profile)
    end
  end

  describe "#call" do
    it "transitions the statement itself" do
      expect {
        subject.call
        statement.reload
      }.to change { statement.type }.from("Finance::Statement::ECF").to("Finance::Statement::ECF::Payable")
    end

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
       .and change(statement.statement_line_items.eligible, :count).from(1).to(0)
       .and change(statement.statement_line_items.payable, :count).from(0).to(1)
       .and not_change(statement.statement_line_items.awaiting_clawback, :count)
       .and not_change(statement.statement_line_items.ineligible, :count)
       .and not_change(statement.statement_line_items.voided, :count)
    end
  end
end
