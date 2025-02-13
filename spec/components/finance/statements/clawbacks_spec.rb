# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Clawbacks, type: :component do
  let(:component) { described_class.new(calculator:) }

  subject { render_inline(component) }

  describe "ECT" do
    let(:calculator) do
      instance_double(
        Finance::ECF::ECT::StatementCalculator,
        clawbacks_breakdown:,
        mentor?: false,
        ect?: true,
        adjustments_total: 160,
        fee_for_declaration: 10,
      )
    end
    let(:clawbacks_breakdown) do
      [
        {
          declaration_type: "Started",
          band: "A",
          count: 1,
          fee: -10.0,
          subtotal: -10.0,
        },
        {
          declaration_type: "Completed",
          band: "A",
          count: 3,
          fee: -10.0,
          subtotal: -30.0,
        },
        {
          declaration_type: "Started",
          band: "B",
          count: 5,
          fee: -10.0,
          subtotal: -50.0,
        },
        {
          declaration_type: "Completed",
          band: "B",
          count: 7,
          fee: -10.0,
          subtotal: -70.0,
        },
      ]
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
    let(:calculator) do
      instance_double(
        Finance::ECF::Mentor::StatementCalculator,
        mentor?: true,
        ect?: false,
        clawbacks_breakdown:,
        adjustments_total: 1_600,
        fee_for_declaration: 20,
      )
    end
    let(:clawbacks_breakdown) do
      [
        {
          declaration_type: "Started",
          count: 10,
          fee: -20.0,
          subtotal: -200.0,
        },
        {
          declaration_type: "Completed",
          count: 70,
          fee: -20.0,
          subtotal: -1400.0,
        },
      ]
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
