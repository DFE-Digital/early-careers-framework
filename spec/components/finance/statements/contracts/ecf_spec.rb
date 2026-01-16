# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Contracts::ECF, type: :component do
  let(:component) { described_class.new(contract:) }
  let(:lead_provider) { instance_double(LeadProvider, name: "Test Provider") }
  let(:contract) do
    instance_double(
      CallOffContract,
      lead_provider:,
      bands:,
      uplift_target: 0.4,
      uplift_amount: 1000,
      recruitment_target: 999,
      set_up_fee: 100,
    )
  end
  let(:bands) do
    [
      instance_double(ParticipantBand, min: 0, max: 10, per_participant: 1000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 11, max: 20, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 21, max: 30, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 31, max: 40, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
    ]
  end

  let(:summary_list) do
    subject.css(".contract-information .govuk-summary-list").map do |list|
      list.css(".govuk-summary-list__row").map do |row|
        row.css(".govuk-summary-list__key, .govuk-summary-list__value").map { |v| v.text.strip }
      end
    end
  end

  let(:band_table) do
    subject.css(".contract-information .govuk-table .govuk-table__row").map do |row|
      row.css(".govuk-table__header, .govuk-table__cell").map { |v| v.text.strip }
    end
  end

  subject { render_inline(component) }

  it "has correct contract" do
    expect(summary_list[0][0][0]).to eq("Provider")
    expect(summary_list[0][0][1]).to eq("Test Provider")

    expect(summary_list[1][0][0]).to eq("Recruitment target")
    expect(summary_list[1][0][1]).to eq("999")

    expect(summary_list[1][1][0]).to eq("Revised recruitment target (+150%)")
    expect(summary_list[1][1][1]).to eq("1499")

    expect(summary_list[1][2][0]).to eq("Uplift target")
    expect(summary_list[1][2][1]).to eq("40%")

    expect(summary_list[1][3][0]).to eq("Uplift amount")
    expect(summary_list[1][3][1]).to eq("£1,000.00")

    expect(summary_list[1][4][0]).to eq("Set-up Fee")
    expect(summary_list[1][4][1]).to eq("£100.00")
  end

  it "has correct bands" do
    expect(band_table[0]).to eq([
      "Band",
      "Min",
      "Max",
      "Payment amount per participant",
    ])

    expect(band_table[1]).to eq([
      "Band A",
      "0",
      "10",
      "£1,000.00",
    ])

    expect(band_table[2]).to eq([
      "Band B",
      "11",
      "20",
      "£2,000.00",
    ])

    expect(band_table[3]).to eq([
      "Band C",
      "21",
      "30",
      "£2,000.00",
    ])

    expect(band_table[4]).to eq([
      "New target",
      "31",
      "40",
      "£2,000.00",
    ])
  end
end
