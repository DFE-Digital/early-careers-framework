# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Contract, type: :component do
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
      revised_target: 1111,
      set_up_fee: 100,
    )
  end
  let(:bands) do
    [
      instance_double(ParticipantBand, min: 0, max: 10, per_participant: 1000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 11, max: 20, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
    ]
  end

  subject { render_inline(component) }

  it "has correct contract" do
    expect(summary_list[0][0][0]).to eq("Provider")
    expect(summary_list[0][0][1]).to eq("Test Provider")

    expect(summary_list[1][0][0]).to eq("Recruitment target")
    expect(summary_list[1][0][1]).to eq("999")

    expect(summary_list[1][1][0]).to eq("Revised recruitment target (+2%)")
    expect(summary_list[1][1][1]).to eq("1111")

    expect(summary_list[1][2][0]).to eq("Uplift target")
    expect(summary_list[1][2][1]).to eq("40%")

    expect(summary_list[1][3][0]).to eq("Uplift amount")
    expect(summary_list[1][3][1]).to eq("£1,000.00")

    expect(summary_list[1][4][0]).to eq("Set-up Fee")
    expect(summary_list[1][4][1]).to eq("£100.00")
  end

  it "has correct bands" do
    expect(band_table[0][0]).to eq("Band")
    expect(band_table[0][1]).to eq("Min")
    expect(band_table[0][2]).to eq("Max")
    expect(band_table[0][3]).to eq("Payment amount per participant")

    expect(band_table[1][0]).to eq("Band A")
    expect(band_table[1][1]).to eq("0")
    expect(band_table[1][2]).to eq("10")
    expect(band_table[1][3]).to eq("£1,000.00")

    expect(band_table[2][0]).to eq("Band B")
    expect(band_table[2][1]).to eq("11")
    expect(band_table[2][2]).to eq("20")
    expect(band_table[2][3]).to eq("£2,000.00")
  end

  def summary_list
    @summary_list ||=
      subject.css(".contract-information .govuk-summary-list").map do |list|
        list.css(".govuk-summary-list__row").map do |row|
          row.css(".govuk-summary-list__key, .govuk-summary-list__value").map { |v| v.text.strip }
        end
      end
  end

  def band_table
    @band_table ||=
      subject.css(".contract-information .govuk-table .govuk-table__row").map do |row|
        row.css(".govuk-table__header, .govuk-table__cell").map { |v| v.text.strip }
      end
  end
end
