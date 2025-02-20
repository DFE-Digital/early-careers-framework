# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::OutputPayments::ECTMentor, type: :component do
  let(:component) { described_class.new(ect_calculator:, mentor_calculator:) }
  let(:ect_calculator) do
    instance_double(
      Finance::ECF::ECT::StatementCalculator,
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
  let(:mentor_calculator) do
    instance_double(
      Finance::ECF::Mentor::StatementCalculator,
      declaration_types_for_display: %i[started completed],
      output_fee: 20_000,

      started_count: 21,
      started_fee_per_declaration: 21.0,
      additions_for_started: 210.0,

      completed_count: 22,
      completed_fee_per_declaration: 22.0,
      additions_for_completed: 220.0,
    )
  end

  let(:ect_outputs) do
    subject.css(".govuk-table")[0].css("tr").map do |row|
      row.css("th, td").map { |v| v.text.strip }
    end
  end

  let(:mentor_outputs) do
    subject.css(".govuk-table")[1].css("tr").map do |row|
      row.css("th, td").map { |v| v.text.strip }
    end
  end

  let(:totals) do
    subject.css("div.govuk-heading-s").map { |v| v.text.strip }
  end

  subject { render_inline(component) }

  describe "ECT" do
    it "has correct heading" do
      expect(subject.css(".govuk-table")[0].css("> caption").text).to eq("Early career teacher (ECT) output payments")
    end

    it "has correct table values" do
      expect(ect_outputs[0]).to eq([
        "Outputs",
        "Band A",
        "Band B",
        "Payments",
      ])

      expect(ect_outputs[1]).to eq([
        "Starts",
        "1",
        "2",
        "",
      ])
      expect(ect_outputs[2]).to eq([
        "Fee per ECT",
        "£10.00",
        "£20.00",
        "£3.00",
      ])

      expect(ect_outputs[3]).to eq([
        "Retained 1",
        "3",
        "4",
        "",
      ])
      expect(ect_outputs[4]).to eq([
        "Fee per ECT",
        "£30.00",
        "£40.00",
        "£7.00",
      ])

      expect(ect_outputs[5]).to eq([
        "Completed",
        "5",
        "6",
        "",
      ])
      expect(ect_outputs[6]).to eq([
        "Fee per ECT",
        "£50.00",
        "£60.00",
        "£11.00",
      ])
    end

    it "has correct total" do
      expect(totals[0]).to eq("ECTs output payment total")
      expect(totals[1]).to eq("£10,000.00")
    end
  end

  describe "Mentor" do
    it "has correct heading" do
      expect(subject.css(".govuk-table")[1].css("> caption").text).to eq("Mentor output payments")
    end

    it "has correct table values" do
      expect(mentor_outputs[0]).to eq(%w[
        Outputs
        Participants
        Payments
      ])

      expect(mentor_outputs[1]).to eq([
        "Starts",
        "21",
        "",
      ])
      expect(mentor_outputs[2]).to eq([
        "Fee per mentor",
        "£21.00",
        "£210.00",
      ])

      expect(mentor_outputs[3]).to eq([
        "Completed",
        "22",
        "",
      ])
      expect(mentor_outputs[4]).to eq([
        "Fee per mentor",
        "£22.00",
        "£220.00",
      ])
    end

    it "has correct total" do
      expect(totals[2]).to eq("Mentors output payment total")
      expect(totals[3]).to eq("£20,000.00")
    end
  end
end
