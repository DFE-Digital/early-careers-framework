# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::MarkAsPayable, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement) do
    create(
      :ecf_statement,
      output_fee: true,
      deadline_date: Date.new(2021, 12, 31),
      cpd_lead_provider:,
    )
  end

  before do
    travel_to Date.new(2021, 12, 31) do
      create(:ect_participant_declaration, :eligible,   cpd_lead_provider:)
      create(:ect_participant_declaration, :ineligible, cpd_lead_provider:)
      create(:ect_participant_declaration, :voided,     cpd_lead_provider:)
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

  it "transitions lines items to payable" do
    expect {
      travel_to Date.new(2022, 1, 1) do
        described_class.perform_now
      end
    }.to change(statement.reload.statement_line_items.payable, :count).from(0).to(1)
  end
end
