# frozen_string_literal: true

require "spec_helper"
require "finance/banding_tracker/participant_per_declaration_type_per_band_aggregator"

RSpec.describe Finance::BandingTracker::ParticipantPerDeclarationTypePerBandAggregator do
  subject(:aggregator) { described_class.new(participants_per_declaration_state, bands) }

  let(:bands)                              { cpd_lead_provider.lead_provider.call_off_contract.participant_bands.min_nulls_first }
  let(:contract)                           { cpd_lead_provider.lead_provider.call_off_contract }
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider).tap do |cpd_lead_provider|
      create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider, revised_target: 65).tap do |call_off_contract|
        band_a, band_b, band_c, band_d = call_off_contract.participant_bands.min_nulls_first
        band_a.update!(min: nil, max: 20)
        band_b.update!(min: 21, max: 40)
        band_c.update!(min: 41, max: 60)
        band_d.update!(min: 61, max: 65)
      end
    end
  end

  let(:participants_per_declaration_state) do
    { "retained-1" => 20, "retained-3" => 8, "retained-2" => 13, "completed" => 2, "retained-4" => 6, "started" => 15 }
  end

  it "aggregates stuff" do
    pending
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "started", band: bands[0])).to eq(15)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "started", band: bands[1])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "started", band: bands[2])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "started", band: bands[3])).to eq(0)

    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-1", band: bands[0])).to eq(5)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-1", band: bands[1])).to eq(15)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-1", band: bands[2])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-1", band: bands[3])).to eq(0)

    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-2", band: bands[0])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-2", band: bands[1])).to eq(5)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-2", band: bands[2])).to eq(8)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-2", band: bands[3])).to eq(0)

    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-3", band: bands[0])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-3", band: bands[1])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-3", band: bands[2])).to eq(8)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-3", band: bands[3])).to eq(0)

    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-4", band: bands[0])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-4", band: bands[1])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-4", band: bands[2])).to eq(4)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "retained-4", band: bands[3])).to eq(2)

    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "completed", band: bands[0])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "completed", band: bands[1])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "completed", band: bands[2])).to eq(0)
    expect(aggregator.participants_for_declaration_type_in_band(declaration_type: "completed", band: bands[3])).to eq(2)
  end
end
