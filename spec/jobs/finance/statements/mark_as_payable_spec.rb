# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::MarkAsPayable do
  include_context "with default schedules"

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement)        { create(:ecf_statement, output_fee: true, deadline_date: Date.new(2021, 12, 31), cpd_lead_provider: cpd_lead_provider) }

  before do
    travel_to Date.new(2021, 12, 31) do
      create(:ect_participant_declaration, :eligible,   statement: statement)
      create(:ect_participant_declaration, :ineligible, statement: statement)
      create(:ect_participant_declaration, :voided,     statement: statement)
    end
  end

  it "transitions eligible declarations to payable", :aggregate_failures do
    expect {
      travel_to Date.new(2022, 1, 1) do
        described_class.perform_now
      end
    }.to change(statement.reload.participant_declarations.payable, :count).from(0).to(1)
    expect(statement.reload.type).to eq("Finance::Statement::ECF::Payable")
  end
end
