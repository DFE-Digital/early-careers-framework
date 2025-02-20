# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::OutputPayments::ECF, type: :component do
  let(:component) { described_class.new(calculator:) }
  let(:calculator) do
    instance_double(
      Finance::ECF::StatementCalculator,
      band_letters: %i[a b],
      event_types_for_display: %i[started retained_1 completed],
      output_fee: 10_000,

      started_band_a_additions: 1,
      started_band_a_fee_per_declaration: 10.0,
      started_band_b_additions: 2,
      started_band_b_fee_per_declaration: 20.0,

      retained_1_band_a_additions: 3,
      retained_1_band_a_fee_per_declaration: 30.0,
      retained_1_band_b_additions: 4,
      retained_1_band_b_fee_per_declaration: 40.0,

      completed_band_a_additions: 5,
      completed_band_a_fee_per_declaration: 50.0,
      completed_band_b_additions: 6,
      completed_band_b_fee_per_declaration: 60.0,

      additions_for_started: 3,
      additions_for_retained_1: 7,
      additions_for_completed: 11,
    )
  end

  let(:ecf_outputs) do
    subject.css(".govuk-table tr").map do |row|
      row.css("th, td").map { |v| v.text.strip }
    end
  end

  let(:totals) do
    subject.css("div.govuk-heading-s").map { |v| v.text.strip }
  end

  subject { render_inline(component) }

  it "has correct heading" do
    expect(subject.css(".govuk-table > caption").text).to eq("Output payments")
  end

  it "has correct table values" do
    expect(ecf_outputs[0]).to eq([
      "Outputs",
      "Band A",
      "Band B",
      "Payments",
    ])

    expect(ecf_outputs[1]).to eq([
      "Starts",
      "1",
      "2",
      "",
    ])
    expect(ecf_outputs[2]).to eq([
      "Fee per participant",
      "£10.00",
      "£20.00",
      "£3.00",
    ])

    expect(ecf_outputs[3]).to eq([
      "Retained 1",
      "3",
      "4",
      "",
    ])
    expect(ecf_outputs[4]).to eq([
      "Fee per participant",
      "£30.00",
      "£40.00",
      "£7.00",
    ])

    expect(ecf_outputs[5]).to eq([
      "Completed",
      "5",
      "6",
      "",
    ])
    expect(ecf_outputs[6]).to eq([
      "Fee per participant",
      "£50.00",
      "£60.00",
      "£11.00",
    ])
  end

  it "has correct total" do
    expect(totals[0]).to eq("Output payment total")
    expect(totals[1]).to eq("£10,000.00")
  end
end
