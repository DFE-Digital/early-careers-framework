# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Clawbacks, type: :component do
  let(:component) { described_class.new(calculator:) }

  subject { render_inline(component) }

  describe "ECT" do
    let(:output_calculator) { instance_double(Finance::ECF::ECT::OutputCalculator, banding_breakdown:) }
    let(:calculator) do
      instance_double(
        Finance::ECF::ECT::StatementCalculator,
        output_calculator:,
        adjustments_total: 160,
        fee_for_declaration: 10,
      )
    end
    let(:banding_breakdown) do
      [
        {
          band: :a,
          min: 1,
          max: 2,
          started_subtractions: 1,
          completed_subtractions: 3,
        },
        {
          band: :b,
          min: 3,
          max: 4,
          started_subtractions: 5,
          completed_subtractions: 7,
        },
      ]
    end

    before do
      allow(calculator).to receive(:is_a?).with(Finance::ECF::Mentor::StatementCalculator).and_return(false)
    end

    it "has correct heading" do
      expect(subject).to have_css(".govuk-table > caption", text: "ECT clawbacks")
    end

    it "has correct table values" do
      expect(table[0]).to eq([
        "Payment type",
        "Number of participants",
        "Fee per participant",
        "Payments",
      ])

      expect(table[1]).to eq([
        "Clawback for Started (Band: A)",
        "1",
        "-£10.00",
        "-£10.00",
      ])

      expect(table[2]).to eq([
        "Clawback for Completed (Band: A)",
        "3",
        "-£10.00",
        "-£30.00",
      ])

      expect(table[3]).to eq([
        "Clawback for Started (Band: B)",
        "5",
        "-£10.00",
        "-£50.00",
      ])

      expect(table[4]).to eq([
        "Clawback for Completed (Band: B)",
        "7",
        "-£10.00",
        "-£70.00",
      ])
    end

    it "has correct total" do
      expect(subject).to have_css("div.govuk-heading-s", text: "£160.00")
    end
  end

  describe "Mentor" do
    let(:output_calculator) { instance_double(Finance::ECF::Mentor::OutputCalculator, output_breakdown:) }
    let(:calculator) do
      instance_double(
        Finance::ECF::Mentor::StatementCalculator,
        output_calculator:,
        adjustments_total: 1_600,
        fee_for_declaration: 20,
      )
    end
    let(:output_breakdown) do
      [
        {
          started_subtractions: 10,
        },
        {
          completed_subtractions: 70,
        },
      ]
    end

    before do
      allow(calculator).to receive(:is_a?).with(Finance::ECF::Mentor::StatementCalculator).and_return(true)
    end

    it "has correct heading" do
      expect(subject).to have_css(".govuk-table > caption", text: "Mentor clawbacks")
    end

    it "has correct table values" do
      expect(table[0]).to eq([
        "Payment type",
        "Number of participants",
        "Fee per participant",
        "Payments",
      ])

      expect(table[1]).to eq([
        "Clawback for Started",
        "10",
        "-£20.00",
        "-£200.00",
      ])

      expect(table[2]).to eq([
        "Clawback for Completed",
        "70",
        "-£20.00",
        "-£1,400.00",
      ])
    end

    it "has correct total" do
      expect(subject).to have_css("div.govuk-heading-s", text: "£1,600.00")
    end
  end

  def table
    @table ||=
      subject.css(".govuk-table tr").map do |row|
        row.css("th, td").map { |v| v.text.strip }
      end
  end
end
